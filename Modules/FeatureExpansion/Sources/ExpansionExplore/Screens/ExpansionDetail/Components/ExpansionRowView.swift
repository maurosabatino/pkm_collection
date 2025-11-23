//
//  ExpansionRowView.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//
import SwiftUI
import CoreKit
import UIComponents

/// Riga di elenco che mostra logo, nome e progressi di un'espansione.
struct ExpansionRowView: View {
    let expansion: Expansion
    @EnvironmentObject private var ownedCardsStore: OwnedCardsStore

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

            VStack(alignment: .leading, spacing: UIConstants.spacingSmall) { 
                Text(expansion.name)
                    .font(.title3.bold())
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(UIConstants.lineLimitSingle)

                Text(FeatureExpansionStrings.releaseDatePrefix + expansion.releaseDate.formatted(date: .numeric, time: .omitted))
                    .font(.caption)
                    .foregroundColor(AppColors.textGray)

                ExpansionProgressView(expansion: expansion)
                    .environmentObject(ownedCardsStore)
            }

        }
        .padding(.vertical, UIConstants.paddingMedium)
        .padding(.horizontal, UIConstants.paddingMedium)
    }
}

// MARK: - Preview for ExpansionRowView
#Preview {
        ExpansionRowView(expansion:
            Expansion(
                id: "swsh1",
                series: FeatureExpansionSamples.expansionSeries1,
                path: "swsh1",
                name: FeatureExpansionSamples.expansionName1,
                num: NumInfo(master: 202, regular: 202),
                hash: "abc",
                abbr: "SSH",
                releaseDate: Date(),
                symbolUrl: "https://images.pokemontcg.io/swsh1/symbol.png",
                logoUrl: "https://images.pokemontcg.io/swsh1/logo.png"
            )
        )
        .padding()
}
