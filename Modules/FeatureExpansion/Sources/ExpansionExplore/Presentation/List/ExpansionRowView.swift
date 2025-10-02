//
//  ExpansionRowView.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//
import SwiftUI

struct ExpansionRowView: View {
    let expansion: Expansion

    var body: some View {
        HStack(spacing: UIConstants.spacingMedium) {
            CachedImageView(
                url: URL(string: expansion.logoUrl),
                size: CGSize(
                    width: UIConstants.symbolImageSize,
                    height: UIConstants.symbolImageSize
                ),
                cornerRadius: UIConstants.cornerRadiusMedium,
                shadowRadius: UIConstants.shadowRadius,
                placeholderColor: AppColors.placeholder,
                errorColor: AppColors.error
            )

            VStack(alignment: .leading, spacing: UIConstants.spacingSmall) { // Organizza il testo e il logo verticalmente.
                Text(expansion.name)
                    .font(.title3.bold())
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(UIConstants.lineLimitSingle)

                Text(AppStrings.releaseDatePrefix + expansion.releaseDate.formatted(date: .numeric, time: .omitted))
                    .font(.caption)
                    .foregroundColor(AppColors.textGray)

                HStack(alignment: .center) {
                    Text(AppStrings.cardsPrefix + "\(expansion.num.regular) / \(expansion.num.master)")
                        .font(.caption.bold())
                        .foregroundColor(AppColors.textBlue)

                    ProgressView(value: Double(expansion.num.regular), total: Double(expansion.num.master))
                        .progressViewStyle(LinearProgressViewStyle(tint: AppColors.progressTint)) 
                        .frame(width: UIConstants.progressBarWidth)
                }
            }

        }
        .padding(.vertical, UIConstants.paddingMedium)
        .padding(.horizontal, UIConstants.paddingMedium)
    }
}

// MARK: - Preview for ExpansionRowView
#Preview {
        ExpansionRowView(expansion:
            Expansion(id: "swsh1", series: "Sword & Shield", path: "swsh1", name: "Spada e Scudo", num: NumInfo(master: 202, regular: 202), hash: "abc", abbr: "SSH", releaseDate: Date(), symbolUrl: "https://images.pokemontcg.io/swsh1/symbol.png", logoUrl: "https://images.pokemontcg.io/swsh1/logo.png")
        )
        .padding()
}
