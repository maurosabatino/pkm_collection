import Foundation
import Combine

public final class LanguageSettings: ObservableObject {
    public static let shared = LanguageSettings()

    private let storageKey = "app.language"
    private let defaults: UserDefaults

    @Published public var language: Language {
        didSet {
            defaults.set(language.rawValue, forKey: storageKey)
        }
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let stored = defaults.string(forKey: storageKey), let lang = Language(rawValue: stored) {
            language = lang
        } else if let localeLang = Language(rawValue: Locale.current.identifier) {
            language = localeLang
        } else {
            language = .itIT
        }
    }
}
