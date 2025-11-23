import SwiftUI
import CoreKit

@MainActor
/// ViewModel che calcola lo snapshot di avanzamento dell'espansione.
final class ExpansionProgressViewModel: ObservableObject {
    @Published private(set) var snapshot: ProgressSnapshot?
    @Published private(set) var isLoading = false

    private let expansion: Expansion
    private let store: CardListStore

    init(expansion: Expansion, store: CardListStore? = nil) {
        self.expansion = expansion
        self.store = store ?? CardListStore(expansionPath: expansion.path)
    }

    func refresh(using ownedStore: OwnedCardsStore) async {
        isLoading = true
        defer { isLoading = false }
        await store.loadCards()
        snapshot = store.progressSnapshot(using: ownedStore)
    }
}

/// Mostra l'avanzamento di completamento di un'espansione con contatori duplicati e wishlist.
struct ExpansionProgressView: View {
    let expansion: Expansion
    @EnvironmentObject private var ownedCardsStore: OwnedCardsStore
    @StateObject private var viewModel: ExpansionProgressViewModel

    init(expansion: Expansion, viewModel: ExpansionProgressViewModel? = nil) {
        self.expansion = expansion
        _viewModel = StateObject(wrappedValue: viewModel ?? ExpansionProgressViewModel(expansion: expansion))
    }

    var body: some View {
        HStack(spacing: UIConstants.spacingMedium) {
            VStack(alignment: .leading, spacing: UIConstants.spacingSmall) {
                Text(progressLabel)
                    .font(.caption.bold())
                    .foregroundColor(AppColors.textBlue)

                ProgressView(value: progressValue, total: 1.0)
                    .progressViewStyle(.linear)
                    .tint(AppColors.progressTint)
                    .frame(width: UIConstants.progressBarWidth)
                    .accessibilityLabel("Completamento \(Int(progressValue * 100))%")
            }

            VStack(alignment: .leading, spacing: 4) {
                Label("\(viewModel.snapshot?.duplicateCards ?? 0)", systemImage: "plus.circle.fill")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                Label("\(viewModel.snapshot?.wishlistCards ?? 0)", systemImage: "bookmark")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .task {
            await viewModel.refresh(using: ownedCardsStore)
        }
    }

    private var progressValue: Double {
        viewModel.snapshot?.completionPercentage ?? 0
    }

    private var progressLabel: String {
        let snapshot = viewModel.snapshot
        let owned = snapshot?.ownedCards ?? 0
        let total = snapshot?.totalCards ?? expansion.num.regular
        return "\(owned)/\(total)"
    }
}

#Preview {
    let expansion = FeatureExpansionSamples.sampleExpansion
    let owned = OwnedCardsStore()
    owned.increment(cardId: "pi1")

    return ExpansionProgressView(expansion: expansion)
        .environmentObject(owned)
        .padding()
        .background(AppColors.cardBackground)
}
