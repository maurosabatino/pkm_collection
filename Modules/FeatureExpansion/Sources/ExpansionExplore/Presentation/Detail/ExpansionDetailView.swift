//
//  ExpansionDetailView.swift
//  PKM Collection
//
//  Created by Mauro on 03/06/25.
//
import SwiftUI
import CoreKit
import UIComponents

// MARK: - ExpansionDetailView

struct ExpansionDetailView: View {
    let expansion: Expansion
    @StateObject private var cardListStore: CardListStore
    @State private var selectedCardForModal: CardViewModel? = nil
    @EnvironmentObject private var ownedCardsStore: OwnedCardsStore

    init(expansion: Expansion, store: CardListStore? = nil) {
        self.expansion = expansion
        _cardListStore = StateObject(wrappedValue: store ?? CardListStore(expansionPath: expansion.path))
    }

    var body: some View {
        VStack {
            Text(FeatureExpansionStrings.expansionDetailsPrefix + expansion.name)
                .font(.largeTitle)
                .padding()

            if !cardListStore.allCardData.isEmpty {
                let snapshot = cardListStore.progressSnapshot(using: ownedCardsStore)
                ExpansionCompletionView(
                    owned: snapshot.ownedCards,
                    total: snapshot.totalCards,
                    duplicates: snapshot.duplicateCards,
                    wishlist: snapshot.wishlistCards,
                    completion: snapshot.completionPercentage
                )
                .padding(.horizontal)
            }

            Picker(FeatureExpansionStrings.displayModeLabel, selection: $cardListStore.displayMode) {
                Text(FeatureExpansionStrings.regularSetMode).tag(CardDisplayMode.regular)
                Text(FeatureExpansionStrings.masterSetMode).tag(CardDisplayMode.master)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, UIConstants.paddingMedium)

            if cardListStore.isLoading {
                ProgressView(FeatureExpansionStrings.loadingCards)
            } else if let error = cardListStore.error {
                VStack(spacing: UIConstants.paddingMedium) {
                    Text(FeatureExpansionStrings.errorLoadingCardsPrefix + error.localizedDescription)
                        .foregroundColor(AppColors.error)
                    Button(FeatureExpansionStrings.retry) {
                        Task { await cardListStore.loadCards() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if cardListStore.displayedCards.isEmpty {
                ContentUnavailableView(
                    FeatureExpansionStrings.noCardsFound,
                    systemImage: "tray.fill",
                    description: Text(FeatureExpansionStrings.checkJsonOrLogic)
                )
            } else {
                CardCatalogGrid(
                    cards: cardListStore.displayedCards,
                    selectedCard: $selectedCardForModal,
                    displayMode: cardListStore.displayMode
                )
            }
        }
        .navigationTitle(expansion.name)
        .searchable(
            text: $cardListStore.searchText,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: FeatureExpansionStrings.searchCardsPlaceholder
        )
        .onAppear {
            Task {
                await cardListStore.loadCards()
            }
        }
        .sheet(item: $selectedCardForModal) { card in
            FullCardModalView(card: card, isShowingModal: Binding(
                get: { selectedCardForModal != nil },
                set: { newValue in
                    if !newValue { selectedCardForModal = nil }
                }
            ))
        }
    }
}

private struct ExpansionCompletionView: View {
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
                Label("\(duplicates)", systemImage: "plus.circle.on.circle")
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

// MARK: - Preview for ExpansionDetailView
struct ExpansionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleExpansion = FeatureExpansionSamples.sampleExpansion
        let mockCardListStore = CardListStore(expansionPath: sampleExpansion.path)
        mockCardListStore.allCardData = FeatureExpansionSamples.sampleCardData

        return NavigationStack {
            ExpansionDetailView(expansion: sampleExpansion, store: mockCardListStore)
                .environmentObject(OwnedCardsStore())
        }
    }
}
