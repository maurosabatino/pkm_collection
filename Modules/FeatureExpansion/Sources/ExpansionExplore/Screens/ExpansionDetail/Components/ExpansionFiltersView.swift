import SwiftUI
import CoreKit
import CoreModels

enum OwnershipFilter: String, CaseIterable, Identifiable {
    case all, owned, missing
    var id: String { rawValue }
    var title: String {
        switch self {
        case .all: return "Tutte"
        case .owned: return "Possedute"
        case .missing: return "Mancanti"
        }
    }
}

/// Foglio filtri del dettaglio espansione con filtri possesso, rarità e display mode.
struct ExpansionFiltersView: View {
    @Binding var ownershipFilter: OwnershipFilter
    @Binding var selectedRarities: Set<Designation>
    let availableRarities: [Designation]
    @Binding var displayMode: CardDisplayMode
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section(FeatureExpansionStrings.displayModeLabel) {
                    Picker(FeatureExpansionStrings.displayModeLabel, selection: $displayMode) {
                        Text(FeatureExpansionStrings.regularSetMode).tag(CardDisplayMode.regular)
                        Text(FeatureExpansionStrings.masterSetMode).tag(CardDisplayMode.master)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Possesso") {
                    Picker("Filtro possesso", selection: $ownershipFilter) {
                        ForEach(OwnershipFilter.allCases) { filter in
                            Text(filter.title).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(FeatureExpansionStrings.filterRaritiesTitle) {
                    if availableRarities.isEmpty {
                        Text(FeatureExpansionStrings.filtersUnavailable)
                            .foregroundColor(AppColors.textSecondary)
                    } else {
                        WrapTagsView(items: availableRarities, isSelected: { selectedRarities.contains($0) }) { rarity in
                            if selectedRarities.contains(rarity) {
                                selectedRarities.remove(rarity)
                            } else {
                                selectedRarities.insert(rarity)
                            }
                        }
                    }
                }
            }
            .navigationTitle(FeatureExpansionStrings.filtersTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(FeatureExpansionStrings.filtersClear) {
                        ownershipFilter = .all
                        selectedRarities = []
                        displayMode = .regular
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(FeatureExpansionStrings.filtersApply) {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Griglia di chip selezionabili riutilizzata per le rarità.
struct WrapTagsView<Item: Hashable>: View {
    let items: [Item]
    let isSelected: (Item) -> Bool
    let action: (Item) -> Void

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: UIConstants.gridSpacing)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: UIConstants.gridSpacing) {
            ForEach(items, id: \.self) { item in
                Button {
                    action(item)
                } label: {
                    Text(label(for: item))
                        .font(.caption)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(isSelected(item) ? AppColors.textBlue.opacity(UIConstants.backgroundOpacityMedium) : AppColors.cardBackground)
                        .foregroundColor(isSelected(item) ? AppColors.textPrimary : AppColors.textSecondary)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(AppColors.textSecondary.opacity(0.2), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, UIConstants.paddingSmall)
    }

    private func label(for item: Item) -> String {
        switch item {
        case let rarity as Designation:
            return rarity.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
        default:
            return String(describing: item)
        }
    }
}
