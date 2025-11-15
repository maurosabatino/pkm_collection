import SwiftUI

public struct LoadingView: View {
    public init() {}

    public var body: some View {
        ProgressView {
            Text(UIComponentsStrings.loadingTitle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
