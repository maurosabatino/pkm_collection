import SwiftUI
import CoreKit
import UIComponents

struct CardCatalogView: View {
    @EnvironmentObject private var expansionStore: ExpansionStore
    @EnvironmentObject private var ownedCardsStore: OwnedCardsStore
    @StateObject private var catalogStore: CardCatalogStore

    @State private var selectedCard: CardViewModel?
    @State private var displayMode: CardDisplayMode = .regular
    @State private var showOwnedOnly = false
    @State private var isFilterSheetPresented = false

    init(store: CardCatalogStore? = nil) {
        _catalogStore = StateObject(wrappedValue: store ?? CardCatalogStore())
    }

    private var cardsToDisplay: [CardViewModel] {
        var cards = catalogStore.displayedCards
        if showOwnedOnly {
            cards = cards.filter { ownedCardsStore.isOwned(cardId: $0.id) }
        }
        return cards
    }

    var body: some View {
        Group {
            if catalogStore.isLoading {
                ProgressView(FeatureExpansionStrings.loadingCards)
            } else if let error = catalogStore.error {
                ContentUnavailableView(
                    FeatureExpansionStrings.errorLoadingCardsPrefix + error.localizedDescription,
                    systemImage: "exclamationmark.triangle.fill"
                )
            } else if cardsToDisplay.isEmpty {
                ContentUnavailableView(
                    FeatureExpansionStrings.noCardsFound,
                    systemImage: "tray.fill",
                    description: Text(FeatureExpansionStrings.checkJsonOrLogic)
                )
            } else {
                VStack(spacing: UIConstants.paddingMedium) {
                    Picker(FeatureExpansionStrings.displayModeLabel, selection: $displayMode) {
                        Text(FeatureExpansionStrings.regularSetMode).tag(CardDisplayMode.regular)
                        Text(FeatureExpansionStrings.masterSetMode).tag(CardDisplayMode.master)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    CardCatalogGrid(
                        cards: cardsToDisplay,
                        selectedCard: $selectedCard,
                        displayMode: displayMode
                    )
                }
            }
        }
        .navigationTitle(FeatureExpansionStrings.cardCatalogTitle)
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
        .searchable(
            text: $catalogStore.searchText,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: FeatureExpansionStrings.searchCardsPlaceholder
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isFilterSheetPresented = true
                } label: {
                    Image(systemName: showOwnedOnly || !catalogStore.selectedPokemonTypes.isEmpty || !catalogStore.selectedRarities.isEmpty ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                }
                .accessibilityLabel(Text(FeatureExpansionStrings.filtersTitle))
            }
        }
        .sheet(item: $selectedCard) { card in
            FullCardModalView(card: card, isShowingModal: Binding(
                get: { selectedCard != nil },
                set: { newValue in
                    if !newValue { selectedCard = nil }
                }
            ))
        }
        .sheet(isPresented: $isFilterSheetPresented) {
            CardCatalogFiltersView(
                store: catalogStore,
                showOwnedOnly: $showOwnedOnly
            )
        }
        .animation(.easeInOut, value: cardsToDisplay)
        .task {
            if catalogStore.displayedCards.isEmpty {
                await catalogStore.loadCards(for: expansionStore.expansions)
            }
        }
        .onChange(of: expansionStore.expansions) { expansions in
            guard !expansions.isEmpty else { return }
            Task {
                await catalogStore.loadCards(for: expansions)
            }
        }
    }
}

struct CardCatalogGrid: View {
    let cards: [CardViewModel]
    @Binding var selectedCard: CardViewModel?
    var displayMode: CardDisplayMode

    @EnvironmentObject private var ownedCardsStore: OwnedCardsStore

    private let columns = [
        GridItem(.adaptive(minimum: UIConstants.cardGridMinimumItemSize), spacing: UIConstants.gridSpacing)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: UIConstants.gridSpacing) {
                ForEach(cards) { card in
                    cardTile(for: card)
                }
            }
            .padding(.horizontal, UIConstants.paddingMedium)
            .padding(.vertical, UIConstants.paddingMedium)
        }
    }

    @ViewBuilder
    private func cardTile(for card: CardViewModel) -> some View {
        VStack(spacing: UIConstants.paddingSmall) {
            CachedImageView(
                url: card.imageUrl,
                size: CGSize(
                    width: UIConstants.cardGridMinimumItemSize,
                    height: UIConstants.cardGridMinimumItemSize * UIConstants.cardImageAspectRatio
                ),
                cornerRadius: UIConstants.cornerRadiusSmall,
                shadowRadius: UIConstants.shadowRadius,
                placeholderColor: AppColors.placeholder,
                errorColor: AppColors.error
            )
            .frame(
                width: UIConstants.cardGridMinimumItemSize,
                height: UIConstants.cardGridMinimumItemSize * UIConstants.cardImageAspectRatio
            )
            .overlay(alignment: .topTrailing) {
                Button {
                    ownedCardsStore.toggleOwnership(for: card.id)
                } label: {
                    Image(systemName: ownedCardsStore.isOwned(cardId: card.id) ? "checkmark.seal.fill" : "plus.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(
                            ownedCardsStore.isOwned(cardId: card.id) ? AppColors.textBlue : AppColors.textSecondary,
                            Color(UIColor.systemBackground)
                        )
                        .padding(6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(ownedCardsStore.isOwned(cardId: card.id) ? "Remove from owned cards" : "Add to owned cards"))
            }
            .onTapGesture {
                selectedCard = card
            }
            .overlay(alignment: .bottomLeading) {
                if ownedCardsStore.quantity(for: card.id) > 1 {
                    Text("x\(ownedCardsStore.quantity(for: card.id))")
                        .font(.caption2.bold())
                        .padding(6)
                        .background(AppColors.badgeBackground)
                        .foregroundColor(AppColors.badgeText)
                        .clipShape(Capsule())
                        .padding(6)
                }
            }

            Text(card.name)
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.horizontal, UIConstants.paddingSmall)
                .lineLimit(UIConstants.lineLimitSingle)
                .background(AppColors.textBlue.opacity(UIConstants.backgroundOpacityLow))
                .cornerRadius(UIConstants.cornerRadiusSmall)

            if displayMode == .master, let foilDescription = card.foilDescription {
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
                ownedCardsStore.increment(cardId: card.id, step: 1)
            }

            if ownedCardsStore.isOwned(cardId: card.id) {
                Button("Remove copy", role: .destructive) {
                    ownedCardsStore.increment(cardId: card.id, step: -1)
                }

                Button("Remove from collection", role: .destructive) {
                    ownedCardsStore.toggleOwnership(for: card.id)
                }
            }
        }
    }
}

private struct CardCatalogFiltersView: View {
    @ObservedObject var store: CardCatalogStore
    @Binding var showOwnedOnly: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section(FeatureExpansionStrings.filterTypesTitle) {
                    if store.availablePokemonTypes.isEmpty {
                        Text(FeatureExpansionStrings.filtersUnavailable)
                            .foregroundColor(AppColors.textSecondary)
                    } else {
                        WrapTagsView(items: store.availablePokemonTypes, isSelected: { store.selectedPokemonTypes.contains($0) }) { type in
                            store.toggleType(type)
                        }
                    }
                }

                Section(FeatureExpansionStrings.filterRaritiesTitle) {
                    if store.availableRarities.isEmpty {
                        Text(FeatureExpansionStrings.filtersUnavailable)
                            .foregroundColor(AppColors.textSecondary)
                    } else {
                        WrapTagsView(items: store.availableRarities, isSelected: { store.selectedRarities.contains($0) }) { rarity in
                            store.toggleRarity(rarity)
                        }
                    }
                }

                Section {
                    Toggle(FeatureExpansionStrings.showOwnedOnly, isOn: $showOwnedOnly)
                }
            }
            .navigationTitle(FeatureExpansionStrings.filtersTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(FeatureExpansionStrings.filtersClear) {
                        store.resetFilters()
                        showOwnedOnly = false
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

private struct WrapTagsView<Item: Hashable>: View {
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
        case let type as PokemonType:
            return type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
        case let rarity as Designation:
            return rarity.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
        default:
            return String(describing: item)
        }
    }
}

#Preview {
    let previewStore = CardCatalogStore()
    previewStore.applySample(cards: FeatureExpansionSamples.sampleCardData)

    return NavigationStack {
        CardCatalogView(store: previewStore)
            .environmentObject(ExpansionStore())
            .environmentObject(OwnedCardsStore())
    }
}
