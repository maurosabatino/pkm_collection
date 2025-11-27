import SwiftUI
import CoreModels
import CoreKit
import Persistence
import UIComponents

public struct DeckDetailView: View {
    let deck: Deck
    @ObservedObject var store: DeckStore
    @ObservedObject var ownedCardsStore: OwnedCardsStore
    private let cardDetailBridge: CardDetailBridge?
    private let lookupRepository: DeckCardLookupRepository

    @State private var cardIdInput: String = ""
    @State private var quantityInput: String = "1"
    @State private var roleInput: String = "main"
    @State private var deckTitle: String = ""
    @State private var displayCards: [DisplayCard] = []
    @State private var isLoading = false
    @State private var isGrid = false
    @State private var selectedCard: SelectedCardViewModel?

    public init(
        deck: Deck,
        store: DeckStore,
        ownedCardsStore: OwnedCardsStore,
        lookupRepository: DeckCardLookupRepository = DatabaseDeckCardLookupRepository(),
        cardDetailBridge: CardDetailBridge? = nil
    ) {
        self.deck = deck
        self.store = store
        self.ownedCardsStore = ownedCardsStore
        self.lookupRepository = lookupRepository
        self.cardDetailBridge = cardDetailBridge
    }

    public var body: some View {
        List {
            Section("Dettagli mazzo") {
                TextField("Nome mazzo", text: $deckTitle)
                Button("Salva nome") {
                    let trimmed = deckTitle.trimmingCharacters(in: .whitespaces)
                    guard trimmed.isEmpty == false else { return }
                    store.updateDeckName(id: deck.id, name: trimmed)
                }
            }

            if isLoading {
                ProgressView("Caricamento carte...")
            }

            if !displayCards.isEmpty {
                Section {
                    Picker("Vista", selection: $isGrid) {
                        Text("Lista").tag(false)
                        Text("Miniature").tag(true)
                    }
                    .pickerStyle(.segmented)
                }

                deckSection(title: "Pokémon", type: .pokemon)
                deckSection(title: "Allenatore", type: .trainer)
                deckSection(title: "Energia", type: .energy)
                deckSection(title: "Altro", type: nil)
            }

            Section("Aggiungi carta") {
                VStack(alignment: .leading, spacing: UIConstants.spacingSmall) {
                    HStack {
                        TextField("Card ID", text: $cardIdInput)
                        TextField("Qty", text: $quantityInput)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                    }
                    Picker("Role", selection: $roleInput) {
                        Text("Main").tag("main")
                        Text("Side").tag("side")
                    }
                    .pickerStyle(.segmented)

                    Button("Add") {
                        guard let qty = Int(quantityInput), !cardIdInput.isEmpty else { return }
                        store.add(cardId: cardIdInput, to: deck.id, quantity: qty, role: roleInput)
                        cardIdInput = ""
                        quantityInput = "1"
                        roleInput = "main"
                        Task { await reload() }
                    }
                }
            }
        }
        .navigationTitle(deck.name)
        .task {
            deckTitle = deck.name
            await reload()
        }
        .onReceive(store.$deckCards) { _ in
            Task { await reload() }
        }
        .sheet(item: $selectedCard) { selected in
            if let bridge = cardDetailBridge {
                bridge.makeCardDetail(
                    card: selected.cardData,
                    ownedStore: ownedCardsStore,
                    isPresented: Binding(
                        get: { selectedCard != nil },
                        set: { if $0 == false { selectedCard = nil } }
                    )
                )
            } else {
                Text(selected.cardData.name)
            }
        }
    }

    private func deckSection(title: String, type: CardType?) -> some View {
        let cardsForSection = displayCards.filter { display in
            if let type {
                return display.card.role == "main" && display.data?.cardType == type
            } else {
                return display.card.role == "main" && display.data?.cardType == nil
            }
        } + displayCards.filter { display in
            display.card.role == "side" && (type == nil || display.data?.cardType == type)
        }

        guard cardsForSection.isEmpty == false else { return AnyView(EmptyView()) }

        if isGrid {
            let columns = [GridItem(.adaptive(minimum: UIConstants.cardGridMinimumItemSize))]
            return AnyView(
                Section(title) {
                    LazyVGrid(columns: columns, spacing: UIConstants.spacingMedium) {
                        ForEach(cardsForSection) { card in
                            Button {
                                openDetail(for: card)
                            } label: {
                                thumbnail(for: card)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            )
        } else {
            return AnyView(
                Section(title) {
                    ForEach(cardsForSection) { card in
                        Button {
                            openDetail(for: card)
                        } label: {
                            row(for: card)
                        }
                        .buttonStyle(.plain)
                    }
                }
            )
        }
    }

    private func thumbnail(for card: DisplayCard) -> some View {
        let data = card.data ?? placeholderCard(id: card.card.cardId)
        let urlString = data.images?.tcgl.tex?.front ?? data.images?.tcgl.png?.front ?? data.images?.tcgl.jpg?.front
        let url = urlString.flatMap(URL.init(string:))
        let width = UIConstants.cardGridMinimumItemSize
        let height = width * UIConstants.cardImageAspectRatio

        return ZStack(alignment: .topTrailing) {
            CachedImageView(
                url: url,
                size: CGSize(width: width, height: height),
                cornerRadius: UIConstants.cornerRadiusSmall,
                shadowRadius: UIConstants.shadowRadius,
                placeholderColor: AppColors.placeholder,
                errorColor: AppColors.error
            )
            .frame(width: width, height: height)

            if card.card.quantity > 0 {
                Text("x\(card.card.quantity)")
                    .font(.caption2.bold())
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.black.opacity(0.7))
                    .clipShape(Capsule())
                    .padding(6)
            }
        }
    }

    private func row(for card: DisplayCard) -> some View {
        HStack(alignment: .top, spacing: UIConstants.spacingSmall) {
            VStack(alignment: .leading, spacing: 2) {
                Text(card.data?.name ?? card.card.cardId)
                    .font(.body)
                if let data = card.data {
                    Text("\(data.collectorNumber.full ?? "") • \(data.rarity?.designation.rawValue ?? "")")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                } else {
                    Text(card.card.cardId)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            Spacer()
            Text("x\(card.card.quantity)")
                .foregroundColor(AppColors.textSecondary)
                .font(.caption)
            VStack(alignment: .trailing, spacing: 2) {
                if let owned = ownedQuantity(for: card.card.cardId), owned > 0 {
                    Text("Possedute: \(owned)")
                        .font(.caption2)
                        .foregroundColor(.green)
                } else {
                    Text("Non posseduta")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                store.remove(cardId: card.card.cardId, from: deck.id, role: card.card.role)
                Task { await reload() }
            } label: {
                Label("Rimuovi", systemImage: "trash")
            }
        }
    }

    @MainActor
    private func reload() async {
        guard isLoading == false else { return }
        isLoading = true
        let cards = store.deckCards[deck.id] ?? []
        let ids = cards.map(\.cardId)
        let details = try? await lookupRepository.fetchCards(ids: ids)
        displayCards = cards.map { card in
            DisplayCard(card: card, data: details?[card.cardId])
        }
        isLoading = false
    }

    @MainActor
    private func ownedQuantity(for cardId: String) -> Int? {
        ownedCardsStore.quantity(for: cardId)
    }

    private func openDetail(for card: DisplayCard) {
        let data = card.data ?? placeholderCard(id: card.card.cardId)
        selectedCard = SelectedCardViewModel(cardData: data)
    }

    private func placeholderCard(id: String) -> CardData {
        CardData(
            name: id,
            cardType: .trainer,
            lang: "en",
            foil: nil,
            size: .standard,
            back: .pokemon1999,
            regulationMark: nil,
            setIcon: "",
            collectorNumber: CollectorNumber(full: id, numerator: nil, denominator: nil, numeric: 0),
            rarity: nil,
            stage: nil,
            hp: nil,
            types: nil,
            weakness: nil,
            resistance: nil,
            retreat: nil,
            text: nil,
            abilities: nil,
            rules: nil,
            flavorText: nil,
            ext: nil,
            images: nil
        )
    }
}

private struct SelectedCardViewModel: Identifiable {
    let cardData: CardData
    var id: String { cardData.id }
}

private struct DisplayCard: Identifiable {
    let card: DeckCard
    let data: CardData?

    var id: String { card.id }
}
