import SwiftUI
import CoreKit
import CoreModels
import UIComponents

/// Mostra la miniatura della carta per la griglia in modo leggero (senza layer foil complessi).
struct CardThumbnailView: View {
    let card: CardViewModel
    let width: CGFloat

    var body: some View {
        let height = width * UIConstants.cardImageAspectRatio

        CachedImageView(
            url: card.imageUrl,
            size: CGSize(width: width, height: height),
            cornerRadius: UIConstants.cornerRadiusSmall,
            shadowRadius: UIConstants.shadowRadius,
            placeholderColor: AppColors.placeholder,
            errorColor: AppColors.error
        )
        .frame(width: width, height: height)
        .contentShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadiusLarge, style: .continuous))
    }
}


#Preview { EmptyView() }
