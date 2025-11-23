import SwiftUI
import CoreKit

// MARK: - ExpansionListView
/// Elenco espansioni raggruppate per serie con navigazione verso dettaglio e catalogo carte.
public struct ExpansionListView: View {
    @EnvironmentObject var expansionStore: ExpansionStore
    @EnvironmentObject var ownedCardsStore: OwnedCardsStore

    public init() {}

    public var body: some View {
        List {
            ForEach(expansionStore.sortedSeriesKeys, id: \.self) { series in
                Section(header: Text(series)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.vertical, UIConstants.paddingSmall)
                ) {
                    ForEach(expansionStore.groupedAndFilteredExpansions[series]!.sorted(by: { $0.releaseDate > $1.releaseDate })) { expansion in
                        NavigationLink(value: expansion) {
                            ExpansionRowView(expansion: expansion)
                                .environmentObject(ownedCardsStore)
                        }
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: UIConstants.cornerRadiusMedium)
                                .fill(AppColors.cardBackground)
                                .shadow(color: AppColors.shadow, radius: UIConstants.shadowRadius, x: UIConstants.shadowOffsetX, y: UIConstants.shadowOffsetY)
                                .padding(.horizontal, UIConstants.paddingMedium)
                                .padding(.vertical, UIConstants.paddingMedium)
                        )
                        .listRowSeparator(.hidden)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(FeatureExpansionStrings.moduleTitle)
        .background(
            AppColors.backgroundPrimary
                .ignoresSafeArea()
        )
        .searchable(
            text: $expansionStore.searchText,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: FeatureExpansionStrings.searchExpansionsPlaceholder
        )
   
        .onAppear {
            if expansionStore.expansions.isEmpty {
                Task {
                    await expansionStore.load()
                }
            }
        }
    }
}




#if DEBUG
private struct PreviewFetchExpansionUseCase: FetchExpansionUseCase {
    func execute() async throws -> [Expansion] {
        FeatureExpansionSamples.sampleExpansions
    }
}
#endif

#Preview {
    let store = ExpansionStore(fetchExpansionUseCase: PreviewFetchExpansionUseCase())
    store.expansions = FeatureExpansionSamples.sampleExpansions

    return NavigationStack {
        ExpansionListView()
            .environmentObject(store)
    }
}
