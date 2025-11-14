import SwiftUI
import CoreKit

// MARK: - ExpansionListView
public struct ExpansionListView: View {
    // Accesso allo store delle espansioni tramite EnvironmentObject.
    @EnvironmentObject var expansionStore: ExpansionStore

    public init() {}

    public var body: some View {
        List {
            // Itera sulle chiavi delle serie ordinate per creare le sezioni.
            ForEach(expansionStore.sortedSeriesKeys, id: \.self) { series in
                Section(header: Text(series)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.vertical, UIConstants.paddingSmall)
                ) {
                    // Itera sulle espansioni all'interno di ogni serie, ordinate per data di rilascio (più recente prima).
                    ForEach(expansionStore.groupedAndFilteredExpansions[series]!.sorted(by: { $0.releaseDate > $1.releaseDate })) { expansion in
                        NavigationLink(value: expansion) {
                            ExpansionRowView(expansion: expansion)
                        }
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: UIConstants.cornerRadiusMedium)
                                .fill(AppColors.cardBackground)
                                .shadow(color: AppColors.shadow, radius: UIConstants.shadowRadius, x: UIConstants.shadowOffsetX, y: UIConstants.shadowOffsetY)
                                .padding(.vertical, UIConstants.paddingSmall)
                        )
                        .listRowSeparator(.hidden)
                        .buttonStyle(PlainButtonStyle())
//                        .listRowInsets(EdgeInsets())
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
        // Aggiunge la barra di ricerca.
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

#Preview {
    ExpansionListView()
        .environmentObject(ExpansionStore())
}
