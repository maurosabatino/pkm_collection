import SwiftUI
import CoreKit

/// Singola card nella griglia con stato possesso/preferenze e azioni rapide.
struct CardGridTileView: View, Equatable {
    let card: CardViewModel
    let props: CardTileProps
    let onSelect: () -> Void
    let onToggleOwned: () -> Void
    let onAddCopy: () -> Void
    let onRemoveCopy: () -> Void

    static func == (lhs: CardGridTileView, rhs: CardGridTileView) -> Bool {
        lhs.props == rhs.props
    }

    var body: some View {
        VStack(spacing: UIConstants.paddingSmall) {
            CardThumbnailView(card: card, width: UIConstants.cardGridMinimumItemSize)
                .overlay(alignment: .topTrailing) {
                    ownershipButton(isOwned: props.isOwned)
                }
                .overlay(alignment: .bottomLeading) {
                    if props.quantity > 1 {
                        QuantityBadgeView(quantity: props.quantity)
                    }
                }
                .onTapGesture {
                    onSelect()
                }

            Text(props.name)
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.horizontal, UIConstants.paddingSmall)
                .lineLimit(UIConstants.lineLimitSingle)
                .background(AppColors.textBlue.opacity(UIConstants.backgroundOpacityLow))
                .cornerRadius(UIConstants.cornerRadiusSmall)

            if let expansionName = props.expansionName {
                Text(expansionName)
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(UIConstants.lineLimitSingle)
                    .padding(.horizontal, UIConstants.paddingSmall)
            }

            if props.displayMode == .master, let foilDescription = props.foilDescription {
                Text(foilDescription)
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, UIConstants.paddingSmall)
                    .background(AppColors.progressTint.opacity(UIConstants.backgroundOpacityLow))
                    .cornerRadius(UIConstants.cornerRadiusSmall)
            }
        }
        .contextMenu {
            Button("Add copy") {
                onAddCopy()
            }

            if props.isOwned {
                Button("Remove copy", role: .destructive) {
                    onRemoveCopy()
                }

                Button("Remove from collection", role: .destructive) {
                    onToggleOwned()
                }
            }
        }
    }

    @ViewBuilder
    private func ownershipButton(isOwned: Bool) -> some View {
        Button {
            onToggleOwned()
        } label: {
            Image(systemName: isOwned ? "checkmark.seal.fill" : "plus.circle.fill")
                .font(.title3)
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    isOwned ? AppColors.textBlue : AppColors.textSecondary,
                    Color(UIColor.systemBackground)
                )
                .padding(6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(isOwned ? "Remove from owned cards" : "Add to owned cards"))
    }
}
