import SwiftUI
import CoreKit

struct SettingsRootView: View {
    @ObservedObject var languageSettings: LanguageSettings

    var body: some View {
        NavigationStack {
            List {
                Section("Lingua dei dati") {
                    ForEach(Language.allCases) { language in
                        Button {
                            languageSettings.language = language
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(language.label)
                                    Text(language.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if languageSettings.language == language {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Impostazioni")
        }
    }
}
