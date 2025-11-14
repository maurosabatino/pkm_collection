import Foundation

enum UIComponentsStrings {
    private static let bundle = Bundle(for: BundleToken.self)

    static var loadingTitle: String {
        localized("uiComponents.loading.title")
    }

    private static func localized(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: nil)
    }

    private final class BundleToken {}
}
