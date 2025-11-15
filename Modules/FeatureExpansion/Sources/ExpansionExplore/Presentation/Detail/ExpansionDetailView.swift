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
    let expansion: Expansion // L'espansione di cui mostrare i dettagli.
    @StateObject private var cardListStore: CardListStore // Store per gestire il caricamento delle carte.
    @State private var selectedCardForModal: CardViewModel? = nil // Stato per la carta da mostrare nella modale
    @EnvironmentObject private var ownedCardsStore: OwnedCardsStore

    // Inizializzatore per iniettare l'espansione e creare lo store delle carte.
    init(expansion: Expansion, store: CardListStore? = nil) {
        self.expansion = expansion
        _cardListStore = StateObject(wrappedValue: store ?? CardListStore(expansionPath: expansion.path))
    }

    var body: some View {
        VStack {
            // Titolo della pagina di dettaglio
            Text(FeatureExpansionStrings.expansionDetailsPrefix + expansion.name)
                .font(.largeTitle)
                .padding()

            // Picker per selezionare la modalità di visualizzazione
            Picker(FeatureExpansionStrings.displayModeLabel, selection: $cardListStore.displayMode) {
                Text(FeatureExpansionStrings.regularSetMode).tag(CardDisplayMode.regular)
                Text(FeatureExpansionStrings.masterSetMode).tag(CardDisplayMode.master)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, UIConstants.paddingMedium)

            // Gestione dello stato di caricamento, errore o dati.
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
                // Griglia per visualizzare le carte.
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: UIConstants.cardGridMinimumItemSize), spacing: UIConstants.gridSpacing)], spacing: UIConstants.gridSpacing) {
                        ForEach(cardListStore.displayedCards) { card in
                            // Ogni card nella griglia.
                            VStack {
                                // Immagine della carta (se disponibile, altrimenti placeholder)
                                CachedImageView(
                                    url: card.imageUrl,
                                    size: CGSize(width: UIConstants.cardGridMinimumItemSize, height: UIConstants.cardGridMinimumItemSize * UIConstants.cardImageAspectRatio),
                                    cornerRadius: UIConstants.cornerRadiusSmall,
                                    shadowRadius: UIConstants.shadowRadius,
                                    placeholderColor: AppColors.placeholder,
                                    errorColor: AppColors.error
                                )
                                .frame(width: UIConstants.cardGridMinimumItemSize, height: UIConstants.cardGridMinimumItemSize * UIConstants.cardImageAspectRatio)
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
                                    selectedCardForModal = card // Imposta la carta da mostrare nella modale
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

                                // Mostra la descrizione del foil SOLO se la modalità è Master Set
                                if cardListStore.displayMode == .master, let foilDescription = card.foilDescription {
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
                    .padding()
                }
            }
        }
        .navigationTitle(expansion.name)
        // Aggiunge la barra di ricerca alla NavigationStack
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
        // Modale per la visualizzazione a schermo intero della carta
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

// MARK: - Preview for ExpansionDetailView
struct ExpansionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Crea un'espansione di esempio per la preview.
        let sampleExpansion = Expansion(
            id: "swsh1",
            series: FeatureExpansionSamples.expansionSeries1,
            path: "swsh1",
            name: FeatureExpansionSamples.expansionName1,
            num: NumInfo(master: 202, regular: 150),
            hash: "abc",
            abbr: "SSH",
            releaseDate: Date(),
            symbolUrl: "https://images.pokemontcg.io/swsh1/symbol.png",
            logoUrl: "https://images.pokemontcg.io/swsh1/logo.png"
        )

        // Crea un CardListStore di esempio con dati fittizi per la preview.
        // In un'app reale, questo caricherebbe da un file JSON.
        let mockCardListStore = CardListStore(expansionPath: sampleExpansion.path)
        // Popola lo store con carte di esempio per la preview
        mockCardListStore.allCardData = [
            CardData(
                name: FeatureExpansionSamples.cardName1,
                cardType: .pokemon,
                lang: "en",
                foil: nil,
                size: .standard,
                back: .pokemon1999,
                regulationMark: nil,
                setIcon: "",
                collectorNumber: CollectorNumber(full: "1/100", numerator: "1", denominator: "100", numeric: 1),
                rarity: nil,
                stage: .basic,
                hp: 60,
                types: [.lightning],
                weakness: nil,
                resistance: nil,
                retreat: 1,
                text: nil,
                abilities: nil,
                rules: nil,
                flavorText: nil,
                ext: Extension(tcgl: TcglExtension(cardID: "pi1", longFormID: "longpi1", archetypeID: "archpi1", reldate: "2020-01-01", key: "keypi1")),
                images: Images(tcgl: TcglImages(tex: ImagePaths(front: "https://images.pokemontcg.io/swsh1/1.png", back: nil, foil: nil, etch: nil), png: ImagePaths(front: "https://images.pokemontcg.io/swsh1/1.png", back: nil, foil: nil, etch: nil), jpg: nil))
            ),
            CardData(
                name: FeatureExpansionSamples.cardName2,
                cardType: .pokemon,
                lang: "en",
                foil: nil,
                size: .standard,
                back: .pokemon1999,
                regulationMark: nil,
                setIcon: "",
                collectorNumber: CollectorNumber(full: "2/100", numerator: "2", denominator: "100", numeric: 2),
                rarity: nil,
                stage: .stage2,
                hp: 160,
                types: [.fire],
                weakness: nil,
                resistance: nil,
                retreat: 3,
                text: nil,
                abilities: nil,
                rules: nil,
                flavorText: nil,
                ext: Extension(tcgl: TcglExtension(cardID: "ch2", longFormID: "longch2", archetypeID: "archch2", reldate: "2020-01-01", key: "keych2")),
                images: Images(tcgl: TcglImages(tex: ImagePaths(front: "https://images.pokemontcg.io/swsh1/2.png", back: nil, foil: nil, etch: nil), png: ImagePaths(front: "https://images.pokemontcg.io/swsh1/2.png", back: nil, foil: nil, etch: nil), jpg: nil))
            ),
            CardData(
                name: FeatureExpansionSamples.cardName3,
                cardType: .pokemon,
                lang: "en",
                foil: nil,
                size: .standard,
                back: .pokemon1999,
                regulationMark: nil,
                setIcon: "",
                collectorNumber: CollectorNumber(full: "3/100", numerator: "3", denominator: "100", numeric: 3),
                rarity: nil,
                stage: .basic,
                hp: 130,
                types: [.psychic],
                weakness: nil,
                resistance: nil,
                retreat: 2,
                text: nil,
                abilities: nil,
                rules: nil,
                flavorText: nil,
                ext: Extension(tcgl: TcglExtension(cardID: "me3", longFormID: "longme3", archetypeID: "archme3", reldate: "2020-01-01", key: "keyme3")),
                images: Images(tcgl: TcglImages(tex: ImagePaths(front: "https://images.pokemontcg.io/swsh1/3.png", back: nil, foil: nil, etch: nil), png: ImagePaths(front: "https://images.pokemontcg.io/swsh1/3.png", back: nil, foil: nil, etch: nil), jpg: nil))
            )
        ]

        return NavigationStack { // Includi in una NavigationStack per vedere il titolo
            ExpansionDetailView(expansion: sampleExpansion, store: mockCardListStore)
                .environmentObject(OwnedCardsStore())
        }
    }
}
