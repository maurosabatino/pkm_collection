import SwiftUI
import CoreKit

struct WishlistRowView: View {
    let wishlist: Wishlist
    let cardCount: Int

    var body: some View {
        HStack(spacing: UIConstants.spacingMedium) {
            Image(systemName: "bookmark")
                .foregroundColor(AppColors.textBlue)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(wishlist.name)
                    .font(.headline)
                if let notes = wishlist.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                Text("\(cardCount) carte")
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
        }
        .padding(.vertical, UIConstants.paddingSmall)
    }
}
