import SwiftUI
import CoreKit

/// Riga descrittiva per coppie titolo/valore nelle schede carta.
struct CardDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(.body)
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Rappresenta una mossa/abilità della carta con badge, costi ed effetto.
struct CardMoveRow: View {
    let move: CardMoveViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(move.title)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                if let badge = move.badgeText {
                    Text(badge.uppercased())
                        .font(.caption2)
                        .padding(.horizontal, UIConstants.paddingSmall)
                        .padding(.vertical, 4)
                        .background(AppColors.textBlue.opacity(0.15))
                        .foregroundColor(AppColors.textBlue)
                        .clipShape(Capsule())
                }
            }

            if let energy = move.energyCost {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    Text(energy)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            if let damage = move.damage {
                Text("Danno: \(damage)")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            if let description = move.description, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
