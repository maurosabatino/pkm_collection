import Foundation
import CoreModels
import Persistence

public final class DeckStore: ObservableObject {
    @Published public private(set) var decks: [Deck] = []
    @Published public private(set) var deckCards: [String: [DeckCard]] = [:] // keyed by deckId

    private let deckDAO: DeckDAO?
    private let deckCardDAO: DeckCardDAO?

    public init(deckDAO: DeckDAO? = DeckDAO(), deckCardDAO: DeckCardDAO? = DeckCardDAO()) {
        self.deckDAO = deckDAO
        self.deckCardDAO = deckCardDAO
        load()
    }

    private func load() {
        decks = (try? deckDAO?.fetchAll()) ?? []
        var map: [String: [DeckCard]] = [:]
        for deck in decks {
            let cards = (try? deckCardDAO?.cards(for: deck.id)) ?? []
            map[deck.id] = cards
        }
        deckCards = map
    }

    public func createDeck(name: String, format: String? = nil, notes: String? = nil) {
        guard let deckDAO else { return }
        let deck = Deck(id: UUID().uuidString, name: name, format: format, notes: notes, updatedAt: Date(), deleted: false)
        decks.append(deck)
        do {
            try deckDAO.save(deck)
        } catch {
            assertionFailure("Failed to save deck: \(error)")
        }
    }

    public func updateDeckName(id: String, name: String) {
        guard let deckDAO, let index = decks.firstIndex(where: { $0.id == id }) else { return }
        var deck = decks[index]
        deck.name = name
        deck.updatedAt = Date()
        decks[index] = deck
        do { try deckDAO.save(deck) } catch { assertionFailure("Failed to update deck: \(error)") }
    }

    public func deleteDeck(id: String) {
        guard let deckDAO else { return }
        decks.removeAll { $0.id == id }
        deckCards[id] = nil
        do {
            try deckDAO.delete(id: id)
            try deckCardDAO?.deleteDeck(id: id)
        } catch {
            assertionFailure("Failed to delete deck: \(error)")
        }
    }

    public func add(cardId: String, to deckId: String, quantity: Int, role: String = "main") {
        guard let deckCardDAO else { return }
        var cards = deckCards[deckId] ?? []
        if let index = cards.firstIndex(where: { $0.cardId == cardId && $0.role == role }) {
            var card = cards[index]
            card.quantity += quantity
            card.updatedAt = Date()
            cards[index] = card
            do { try deckCardDAO.upsert(card) } catch { assertionFailure("Failed to upsert deck card: \(error)") }
        } else {
            let card = DeckCard(deckId: deckId, cardId: cardId, quantity: quantity, role: role, updatedAt: Date(), deleted: false)
            cards.append(card)
            do { try deckCardDAO.upsert(card) } catch { assertionFailure("Failed to upsert deck card: \(error)") }
        }
        deckCards[deckId] = cards
    }

    public func remove(cardId: String, from deckId: String, role: String = "main") {
        guard let deckCardDAO else { return }
        var cards = deckCards[deckId] ?? []
        cards.removeAll { $0.cardId == cardId && $0.role == role }
        deckCards[deckId] = cards
        do { try deckCardDAO.delete(deckId: deckId, cardId: cardId, role: role) } catch {
            assertionFailure("Failed to delete deck card: \(error)")
        }
    }
}
