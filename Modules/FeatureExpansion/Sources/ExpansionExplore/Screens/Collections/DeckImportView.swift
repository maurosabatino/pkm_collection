import SwiftUI
import CoreKit

struct DeckImportView: View {
    @ObservedObject var deckStore: DeckStore
    @ObservedObject var ownedCardsStore: OwnedCardsStore
    private let resolver: DeckCardResolver = .init()

    @State private var deckName: String = ""
    @State private var deckText: String = ""
    @State private var parseResult: DeckImportResult = .init(cards: [], totalCount: 0)
    @State private var resolved: [ResolvedImportCard] = []
    @State private var isResolving = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Importa mazzo")
                .font(.title2.weight(.semibold))

            TextField("Nome mazzo", text: $deckName)
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $deckText)
                .frame(minHeight: 200)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                .onChange(of: deckText) { newValue in
                    parseResult = DeckImportParser.parse(newValue)
                    Task { await resolveCards() }
                }

            HStack {
                Text("Carte trovate: \(parseResult.cards.count) • Totale copie: \(parseResult.totalCount)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Button(isResolving ? "Risoluzione..." : "Importa") {
                    importDeck()
                }
                .buttonStyle(.borderedProminent)
                .disabled(parseResult.cards.isEmpty || deckName.isEmpty || isResolving)
            }

            if parseResult.cards.isEmpty == false {
                List(resolved.isEmpty ? parseResult.cards.map { ResolvedImportCard(parsed: $0, resolvedId: nil, card: nil) } : resolved, id: \.id) { card in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(card.card?.name ?? card.parsed.name)
                            Text("\(card.parsed.setCode) \(card.parsed.number)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("x\(card.parsed.quantity)")
                            .font(.headline)
                        if card.resolvedId == nil {
                            Text("Non trovata")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
            } else {
                Spacer()
            }
        }
        .padding()
    }

    private func importDeck() {
        guard parseResult.cards.isEmpty == false else { return }
        deckStore.createDeck(name: deckName)
        guard let deckId = deckStore.decks.last?.id else { return }
        for item in resolved {
            let cardId = item.resolvedId ?? item.parsed.cardId
            deckStore.add(cardId: cardId, to: deckId, quantity: item.parsed.quantity)
            if !ownedCardsStore.isOwned(cardId: cardId) && !ownedCardsStore.isWishlist(cardId: cardId) {
                ownedCardsStore.toggleWishlist(for: cardId)
            }
        }
        deckName = ""
        deckText = ""
        parseResult = .init(cards: [], totalCount: 0)
        resolved = []
    }

    @MainActor
    private func resolveCards() async {
        isResolving = true
        resolved = await resolver.resolve(parseResult.cards)
        isResolving = false
    }
}
