import SwiftUI
import CoreKit

public final class FeatureSettingsModule: FeatureModule {
    private enum Entry: String {
        case settings
    }

    private let languageSettings: LanguageSettings
    private let moduleId = "feature.settings"

    public init(languageSettings: LanguageSettings) {
        self.languageSettings = languageSettings
    }

    public var metadata: ModuleMetadata {
        ModuleMetadata(
            id: moduleId,
            title: LocalizedStringKey("Impostazioni"),
            systemImage: "gearshape.fill"
        )
    }

    public func entryPoints(using navigator: ModuleNavigator) -> [ModuleEntryDescriptor] {
        [
            ModuleEntryDescriptor(
                moduleId: metadata.id,
                id: Entry.settings.rawValue,
                title: metadata.title,
                systemImage: metadata.systemImage
            ) { [weak self] _ in
                guard let self else { return AnyView(EmptyView()) }
                return AnyView(
                    SettingsRootView(languageSettings: self.languageSettings)
                )
            }
        ]
    }
}
