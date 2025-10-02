import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CustomHeaderView: View {
    let title: String
    let imageName: String
    let imageColor: Color
    
    @Binding var isScrolledToTop: Bool

    var body: some View {
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
