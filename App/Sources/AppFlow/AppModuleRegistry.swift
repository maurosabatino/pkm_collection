import Foundation
import CoreKit
import FeatureExpansion

@MainActor
final class AppModuleRegistry: ObservableObject {
    let navigator = ModuleNavigator()
    let modules: [AnyFeatureModule]
    let entries: [ModuleEntryDescriptor]

    init() {
        let expansionModule = FeatureExpansionModule()
        let featureModules = [AnyFeatureModule(expansionModule)]
        self.modules = featureModules
        let localNavigator = navigator
        self.entries = featureModules.flatMap { $0.entryPoints(using: localNavigator) }
    }
}
