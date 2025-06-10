// MARK: - Main JSON Structure
struct Expansion: Codable {
    let enUS: [String: SetInfo]
    let frFR: [String: SetInfo]
    let itIT: [String: SetInfo]
    let deDE: [String: SetInfo]
    let esES: [String: SetInfo]
    let ptBR: [String: SetInfo]
    let es419: [String: SetInfo]

    enum CodingKeys: String, CodingKey {
        case enUS = "en-US"
        case frFR = "fr-FR"
        case itIT = "it-IT"
        case deDE = "de-DE"
        case esES = "es-ES"
        case ptBR = "pt-BR"
        case es419 = "es-419"
    }

    func sets(for language: Language) -> [SetInfo] {
        switch language {
        case .enUS: return Array(enUS.values)
        case .frFR: return Array(frFR.values)
        case .itIT: return Array(itIT.values)
        case .deDE: return Array(deDE.values)
        case .esES: return Array(esES.values)
        case .ptBR: return Array(ptBR.values)
        case .es419: return Array(es419.values)
        }
    }
}

struct SetInfo: Codable, Identifiable {
    let path: String
    let name: String
    let num: Int
    let hash: String
    let abbr: String

    var id: String { path }
}

enum Language: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }

    case enUS = "en-US"
    case frFR = "fr-FR"
    case itIT = "it-IT"
    case deDE = "de-DE"
    case esES = "es-ES"
    case ptBR = "pt-BR"
    case es419 = "es-419"

    var label: String {
        switch self {
        case .enUS: return "🇺🇸 English"
        case .frFR: return "🇫🇷 Français"
        case .itIT: return "🇮🇹 Italiano"
        case .deDE: return "🇩🇪 Deutsch"
        case .esES: return "🇪🇸 Español"
        case .ptBR: return "🇧🇷 Português"
        case .es419: return "🌎 Español LatAm"
        }
    }
}
