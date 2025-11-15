import SwiftUI

public struct ModuleMetadata: Identifiable, Hashable {
    public let id: String
    public let title: LocalizedStringKey
    public let systemImage: String

    public init(id: String, title: LocalizedStringKey, systemImage: String) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
    }

    public static func == (lhs: ModuleMetadata, rhs: ModuleMetadata) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct ModuleRoute: Hashable {
    public let moduleIdentifier: String
    public let entryIdentifier: String
    public let payload: AnyHashable?

    public init(moduleIdentifier: String, entryIdentifier: String, payload: AnyHashable? = nil) {
        self.moduleIdentifier = moduleIdentifier
        self.entryIdentifier = entryIdentifier
        self.payload = payload
    }
}

public final class ModuleNavigator: ObservableObject {
    @Published public private(set) var pendingRoute: ModuleRoute?

    public init() {}

    public func navigate(to route: ModuleRoute) {
        pendingRoute = route
    }

    public func clear() {
        pendingRoute = nil
    }
}

public struct ModuleEntryDescriptor: Identifiable, Hashable {
    public let moduleId: String
    public let id: String
    public let title: LocalizedStringKey
    public let systemImage: String
    private let builder: (ModuleNavigator) -> AnyView

    public init(
        moduleId: String,
        id: String,
        title: LocalizedStringKey,
        systemImage: String,
        build: @escaping (ModuleNavigator) -> AnyView
    ) {
        self.moduleId = moduleId
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.builder = build
    }

    public func makeView(navigator: ModuleNavigator) -> AnyView {
        builder(navigator)
    }

    public static func == (lhs: ModuleEntryDescriptor, rhs: ModuleEntryDescriptor) -> Bool {
        lhs.moduleId == rhs.moduleId && lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(moduleId)
        hasher.combine(id)
    }
}

public protocol FeatureModule: AnyObject {
    var metadata: ModuleMetadata { get }
    func entryPoints(using navigator: ModuleNavigator) -> [ModuleEntryDescriptor]
}

public struct AnyFeatureModule: Identifiable {
    public var id: String { metadata.id }
    public let metadata: ModuleMetadata
    private let entryBuilder: (ModuleNavigator) -> [ModuleEntryDescriptor]

    public init(_ module: FeatureModule) {
        self.metadata = module.metadata
        self.entryBuilder = { navigator in
            module.entryPoints(using: navigator)
        }
    }

    public func entryPoints(using navigator: ModuleNavigator) -> [ModuleEntryDescriptor] {
        entryBuilder(navigator)
    }
}
