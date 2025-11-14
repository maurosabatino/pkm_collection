import SwiftUI

public struct ScrollOffsetPreferenceKey: PreferenceKey {
    public static var defaultValue: CGFloat = .zero

    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

public struct CustomHeaderView: View {
    private let title: String
    private let imageName: String
    private let imageColor: Color
    @Binding private var isScrolledToTop: Bool

    public init(title: String, imageName: String, imageColor: Color, isScrolledToTop: Binding<Bool>) {
        self.title = title
        self.imageName = imageName
        self.imageColor = imageColor
        self._isScrolledToTop = isScrolledToTop
    }

    public var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(imageColor)
                .font(isScrolledToTop ? .title2 : .headline)
                .scaleEffect(isScrolledToTop ? 1.2 : 1.0)

            Text(title)
                .font(isScrolledToTop ? .largeTitle : .headline)
                .fontWeight(isScrolledToTop ? .bold : .regular)
                .foregroundColor(.primary)
        }
        .animation(.easeInOut, value: isScrolledToTop)
    }
}
