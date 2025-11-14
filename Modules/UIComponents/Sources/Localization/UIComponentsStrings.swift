import Foundation

enum UIComponentsStrings {
    private static let bundle = Bundle(for: BundleToken.self)
    private static let table = "UIComponents"

    static var loadingTitle: String {
        localized("uiComponents.loading.title")
    }

    private static func localized(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: table)
    }

    private final class BundleToken {}
}
