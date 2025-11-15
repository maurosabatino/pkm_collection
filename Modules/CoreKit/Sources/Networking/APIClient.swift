import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: - Core Types

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public enum APIClientError: Error {
    case invalidURL
    case circuitOpen(until: Date)
}

public struct APIHTTPError: Error, LocalizedError {
    public let statusCode: Int
    public let data: Data?

    public init(statusCode: Int, data: Data?) {
        self.statusCode = statusCode
        self.data = data
    }

    public var errorDescription: String? {
        "HTTP status code: \(statusCode)"
    }
}

public enum APIRequestResult {
    case success(URLResponse, Data)
    case failure(Error)
}

public protocol APIRequestInterceptor {
    func adapt(_ request: URLRequest) async throws -> URLRequest
    func didReceive(_ result: APIRequestResult, for request: URLRequest) async
}

public extension APIRequestInterceptor {
    func adapt(_ request: URLRequest) async throws -> URLRequest { request }
    func didReceive(_ result: APIRequestResult, for request: URLRequest) async { }
}

public protocol APIResponseCaching {
    func cachedResponse(for request: URLRequest) -> CachedURLResponse?
    func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest)
}

extension URLCache: APIResponseCaching {}

public struct CachePolicy {
    public enum Mode: Equatable {
        case disabled
        case preferCache
        case fallbackOnError
    }

    public let mode: Mode
    public let requestPolicy: URLRequest.CachePolicy
    public let cache: APIResponseCaching?

    public init(
        mode: Mode,
        requestPolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        cache: APIResponseCaching? = URLCache.shared
    ) {
        self.mode = mode
        self.requestPolicy = requestPolicy
        self.cache = cache
    }

    public static let disabled = CachePolicy(mode: .disabled, cache: nil)

    public static func preferCache(
        policy: URLRequest.CachePolicy = .returnCacheDataElseLoad,
        cache: APIResponseCaching = URLCache.shared
    ) -> CachePolicy {
        CachePolicy(mode: .preferCache, requestPolicy: policy, cache: cache)
    }

    public static func fallbackOnError(
        policy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        cache: APIResponseCaching = URLCache.shared
    ) -> CachePolicy {
        CachePolicy(mode: .fallbackOnError, requestPolicy: policy, cache: cache)
    }
}

public struct RetryPolicy {
    public enum BackoffStrategy {
        case immediate
        case fixed(TimeInterval)
        case exponential(initial: TimeInterval, multiplier: Double, maxDelay: TimeInterval? = nil)
        case custom((Int) -> TimeInterval)
    }

    public struct CircuitBreaker {
        public let failureThreshold: Int
        public let recoveryTimeInterval: TimeInterval

        public init(failureThreshold: Int, recoveryTimeInterval: TimeInterval) {
            self.failureThreshold = failureThreshold
            self.recoveryTimeInterval = recoveryTimeInterval
        }
    }

    public let maxRetries: Int
    public let strategy: BackoffStrategy
    public let retryableStatusCodes: Set<Int>
    public let retryableURLErrorCodes: Set<URLError.Code>
    public let circuitBreaker: CircuitBreaker?

    public init(
        maxRetries: Int,
        strategy: BackoffStrategy = .fixed(0.5),
        retryableStatusCodes: Set<Int> = Set(500..<600),
        retryableURLErrorCodes: Set<URLError.Code> = [.timedOut, .cannotConnectToHost, .networkConnectionLost],
        circuitBreaker: CircuitBreaker? = nil
    ) {
        self.maxRetries = maxRetries
        self.strategy = strategy
        self.retryableStatusCodes = retryableStatusCodes
        self.retryableURLErrorCodes = retryableURLErrorCodes
        self.circuitBreaker = circuitBreaker
    }

    public func delay(for attempt: Int) -> TimeInterval {
        guard attempt > 0 else { return 0 }
        switch strategy {
        case .immediate:
            return 0
        case .fixed(let value):
            return value
        case .exponential(let initial, let multiplier, let maxDelay):
            let delay = initial * pow(multiplier, Double(max(attempt - 1, 0)))
            if let maxDelay { return min(delay, maxDelay) }
            return delay
        case .custom(let closure):
            return closure(attempt)
        }
    }

    public func shouldRetry(error: Error) -> Bool {
        if let httpError = error as? APIHTTPError {
            return retryableStatusCodes.contains(httpError.statusCode)
        }
        if let urlError = error as? URLError {
            return retryableURLErrorCodes.contains(urlError.code)
        }
        return false
    }
}

public protocol CatalogDecoderProviding {
    func decoder<Request: APICatalog>(for request: Request, defaultDecoder: JSONDecoder) -> JSONDecoder
}

public struct DefaultCatalogDecoderProvider: CatalogDecoderProviding {
    public init() { }

    public func decoder<Request: APICatalog>(for request: Request, defaultDecoder: JSONDecoder) -> JSONDecoder {
        request.decoder ?? defaultDecoder
    }
}

// MARK: - Catalog Contracts

public protocol APICatalog {
    associatedtype Response: Decodable

    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    func body() throws -> Data?
    var decoder: JSONDecoder? { get }
    var timeoutInterval: TimeInterval { get }
    var identifier: String { get }
    var interceptors: [APIRequestInterceptor] { get }
    var retryPolicy: RetryPolicy? { get }
    var cachePolicy: CachePolicy { get }
}

public extension APICatalog {
    var headers: [String: String]? { nil }
    var queryItems: [URLQueryItem]? { nil }
    func body() throws -> Data? { nil }
    var decoder: JSONDecoder? { nil }
    var timeoutInterval: TimeInterval { 30 }
    var identifier: String { String(describing: Self.self) }
    var interceptors: [APIRequestInterceptor] { [] }
    var retryPolicy: RetryPolicy? { nil }
    var cachePolicy: CachePolicy { .disabled }

    func makeURLRequest() throws -> URLRequest {
        var url = baseURL
        if !path.isEmpty {
            url.appendPathComponent(path)
        }

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw APIClientError.invalidURL
        }
        if let queryItems = queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let finalURL = components.url else {
            throw APIClientError.invalidURL
        }

        var request = URLRequest(url: finalURL, timeoutInterval: timeoutInterval)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = try body()
        return request
    }
}

// MARK: - Client

public protocol APIClientProtocol {
    func send<Request: APICatalog>(_ request: Request) async throws -> Request.Response
}

public final class APIClient: APIClientProtocol {

    private let session: URLSession
    private let defaultDecoder: JSONDecoder
    private let decoderProvider: CatalogDecoderProviding
    private let logger: LoggerProtocol
    private let circuitBreakerStore = CircuitBreakerStore()

    public init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        decoderProvider: CatalogDecoderProviding = DefaultCatalogDecoderProvider(),
        logger: LoggerProtocol = Log.network
    ) {
        self.session = session
        self.defaultDecoder = decoder
        self.decoderProvider = decoderProvider
        self.logger = logger
    }

    public func send<Request: APICatalog>(_ request: Request) async throws -> Request.Response {
        if let breaker = request.retryPolicy?.circuitBreaker {
            try await circuitBreakerStore.ensureCanProceed(identifier: request.identifier, breaker: breaker)
        }

        var urlRequest = try request.makeURLRequest()
        urlRequest.cachePolicy = request.cachePolicy.requestPolicy
        urlRequest = try await applyInterceptors(request.interceptors, to: urlRequest)

        if let cachedResponse = try fetchCachedResponseIfNeeded(request: request, urlRequest: urlRequest, mode: .preferCache) {
            return cachedResponse
        }

        var attempt = 0

        while true {
            do {
                logger.info("➡️ \(request.identifier) \(urlRequest.url?.absoluteString ?? "URL non valido")")
                logger.debug(formatRequestLog(urlRequest))

                let (data, response) = try await session.data(for: urlRequest)

                logger.info("⬅️ \(request.identifier) completata")
                logger.debug(formatResponseLog(response: response, data: data))

                try validate(response: response, data: data)

                if let cache = request.cachePolicy.cache,
                   request.cachePolicy.mode != .disabled,
                   let httpResponse = response as? HTTPURLResponse {
                    let cached = CachedURLResponse(response: httpResponse, data: data)
                    cache.storeCachedResponse(cached, for: urlRequest)
                }

                await notifyInterceptors(request.interceptors, result: .success(response, data), request: urlRequest)
                if request.retryPolicy?.circuitBreaker != nil {
                    await circuitBreakerStore.reset(identifier: request.identifier)
                }

                return try decode(data: data, for: request)
            } catch {
                logger.error(error.localizedDescription)
                await notifyInterceptors(request.interceptors, result: .failure(error), request: urlRequest)

                if let cachedResponse = try fetchCachedResponseIfNeeded(request: request, urlRequest: urlRequest, mode: .fallbackOnError) {
                    return cachedResponse
                }

                guard let policy = request.retryPolicy,
                      attempt < policy.maxRetries,
                      policy.shouldRetry(error: error) else {
                    if let breaker = request.retryPolicy?.circuitBreaker {
                        await circuitBreakerStore.registerFailure(identifier: request.identifier, breaker: breaker)
                    }
                    throw error
                }

                attempt += 1
                let delay = policy.delay(for: attempt)
                logger.warning("🔁 Retry \(attempt)/\(policy.maxRetries) per \(request.identifier) in \(delay)s")
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }

    private func decode<Request: APICatalog>(data: Data, for request: Request) throws -> Request.Response {
        let decoder = decoderProvider.decoder(for: request, defaultDecoder: defaultDecoder)
        do {
            return try decoder.decode(Request.Response.self, from: data)
        } catch let decodingError as DecodingError {
            logger.error(formatDecodingError(decodingError, for: request.identifier, dataType: Request.Response.self))
            throw decodingError
        }
    }

    private func applyInterceptors(
        _ interceptors: [APIRequestInterceptor],
        to request: URLRequest
    ) async throws -> URLRequest {
        var current = request
        for interceptor in interceptors {
            current = try await interceptor.adapt(current)
        }
        return current
    }

    private func notifyInterceptors(
        _ interceptors: [APIRequestInterceptor],
        result: APIRequestResult,
        request: URLRequest
    ) async {
        for interceptor in interceptors {
            await interceptor.didReceive(result, for: request)
        }
    }

    private func fetchCachedResponseIfNeeded<Request: APICatalog>(
        request: Request,
        urlRequest: URLRequest,
        mode: CachePolicy.Mode
    ) throws -> Request.Response? {
        guard request.cachePolicy.mode == mode,
              let cached = request.cachePolicy.cache?.cachedResponse(for: urlRequest) else {
            return nil
        }
        logger.info("📦 Cache hit per \(request.identifier) [mode: \(String(describing: mode))]")
        return try decode(data: cached.data, for: request)
    }

    private func validate(response: URLResponse?, data: Data?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIHTTPError(statusCode: httpResponse.statusCode, data: data)
        }
    }

    // MARK: - Log Helpers

    private func formatRequestLog(_ request: URLRequest) -> String {
        """
        [RICHIESTA]
          - URL: \(request.url?.absoluteString ?? "N/A")
          - Metodo: \(request.httpMethod ?? "N/A")
          - Header:
        \(request.allHTTPHeaderFields?.prettyPrinted ?? "    -")
          - Body:
        \(request.httpBody.toPrettyPrintedString)
        """
    }

    private func formatResponseLog(response: URLResponse?, data: Data?) -> String {
        guard let httpResponse = response as? HTTPURLResponse else {
            return "[RISPOSTA NON-HTTP]"
        }
        return """
        [RISPOSTA]
          - Status Code: \(httpResponse.statusCode)
          - URL: \(httpResponse.url?.absoluteString ?? "N/A")
          - Header:
        \(httpResponse.allHeaderFields.prettyPrinted)
          - Body:
        \(data.toPrettyPrintedString)
        """
    }

    private func formatDecodingError<T>(_ error: DecodingError, for endpoint: String, dataType: T.Type) -> String {
        """
        [ERRORE DI DECODIFICA]
          - Endpoint: \(endpoint)
          - Tipo Atteso: \(String(describing: dataType))
          - Errore: \(error.localizedDescription)
        """
    }
}

private actor CircuitBreakerStore {
    private struct State {
        var failureCount: Int = 0
        var openUntil: Date?
    }

    private var states: [String: State] = [:]

    func ensureCanProceed(identifier: String, breaker: RetryPolicy.CircuitBreaker) async throws {
        if let state = states[identifier], let openUntil = state.openUntil, openUntil > Date() {
            throw APIClientError.circuitOpen(until: openUntil)
        }
    }

    func registerFailure(identifier: String, breaker: RetryPolicy.CircuitBreaker) async {
        var state = states[identifier] ?? State()
        state.failureCount += 1
        if state.failureCount >= breaker.failureThreshold {
            state.openUntil = Date().addingTimeInterval(breaker.recoveryTimeInterval)
            state.failureCount = 0
        }
        states[identifier] = state
    }

    func reset(identifier: String) async {
        states[identifier] = nil
    }
}

// MARK: - Helper Extensions

private extension Optional where Wrapped == Data {
    var toPrettyPrintedString: String {
        guard let data = self, !data.isEmpty else { return "    -" }
        guard let obj = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return String(data: data, encoding: .utf8) ?? "Dati non decodificabili"
        }
        return prettyString.split(separator: "\n").map { "    \($0)" }.joined(separator: "\n")
    }
}

private extension Dictionary where Key == AnyHashable, Value == Any {
    var prettyPrinted: String {
        guard !self.isEmpty else { return "    -" }
        return self.map { "    \($0.key): \($0.value)" }.joined(separator: "\n")
    }
}

private extension Dictionary where Key == String, Value == String {
    var prettyPrinted: String {
        guard !self.isEmpty else { return "    -" }
        return self.map { "    \($0.key): \($0.value)" }.joined(separator: "\n")
    }
}

#if canImport(SwiftUI)
private struct APIClientEnvironmentKey: EnvironmentKey {
    static var defaultValue: APIClientProtocol = APIClient()
}

public extension EnvironmentValues {
    var apiClient: APIClientProtocol {
        get { self[APIClientEnvironmentKey.self] }
        set { self[APIClientEnvironmentKey.self] = newValue }
    }
}
#endif // canImport(SwiftUI)
