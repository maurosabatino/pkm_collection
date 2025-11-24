import SwiftUI
import CoreKit

struct DeckRowView: View {
    let deck: Deck
    let cardCount: Int

    var body: some View {
        HStack(spacing: UIConstants.spacingMedium) {
            Image(systemName: "rectangle.stack.badge.play")
                .foregroundColor(AppColors.textBlue)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(deck.name)
                    .font(.headline)
                if let format = deck.format, !format.isEmpty {
                    Text(format)
                        .font(.caption2)
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
