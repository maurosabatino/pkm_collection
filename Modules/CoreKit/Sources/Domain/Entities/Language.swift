//
//  Language\.swift
//  PKM Collection
//
//  Created by Mauro on 15/06/25.
//

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
