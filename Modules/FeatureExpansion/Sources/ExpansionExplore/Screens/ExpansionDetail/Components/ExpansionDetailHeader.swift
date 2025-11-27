import SwiftUI
import CoreKit
import CoreModels

/// Box che mostra avanzamento, duplicati e wishlist dell'espansione.
struct ExpansionCompletionView: View {
    let owned: Int
    let total: Int
    let duplicates: Int
    let wishlist: Int
    let completion: Double

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.paddingSmall) {
            HStack {
                Text("Progressi set")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("\(owned)/\(total)")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }

            ProgressView(value: total > 0 ? Double(owned) / Double(total) : 0)
                .tint(AppColors.progressTint)
                .accessibilityLabel("Completamento set \(Int((completion * 100).rounded()))%")

            HStack(spacing: UIConstants.paddingMedium) {
                Label("\(duplicates)", systemImage: "plus.circle.fill")
                    .foregroundColor(AppColors.textSecondary)
                Label("\(wishlist)", systemImage: "bookmark")
                    .foregroundColor(AppColors.textSecondary)
            }
            .font(.footnote)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .cornerRadius(UIConstants.cornerRadiusLarge)
    }
}

/// Header che impagina il riepilogo dei progressi dell'espansione.
struct ExpansionDetailHeader: View {
    let expansion: Expansion
    let snapshot: ProgressSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.paddingSmall) {
            ExpansionCompletionView(
                owned: snapshot.ownedCards,
                total: snapshot.totalCards,
                duplicates: snapshot.duplicateCards,
                wishlist: snapshot.wishlistCards,
                completion: snapshot.completionPercentage
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
