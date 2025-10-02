import SwiftUI

@MainActor
public final class OwnedCardsStore: ObservableObject {
    @Published private(set) var ownedCards: [String: OwnedCard] = [:]

    private let persistence: OwnedCardsPersistence

    public init(persistence: OwnedCardsPersistence = FileOwnedCardsPersistence()) {
        self.persistence = persistence
        loadFromDisk()
    }

    public func isOwned(cardId: String) -> Bool {
        ownedCards[cardId]?.quantity ?? 0 > 0
    }

    public func quantity(for cardId: String) -> Int {
        ownedCards[cardId]?.quantity ?? 0
    }

    public func toggleOwnership(for cardId: String) {
        if let existing = ownedCards[cardId], existing.quantity > 0 {
            ownedCards[cardId] = nil
        } else {
            ownedCards[cardId] = OwnedCard(cardId: cardId)
        }
        persist()
    }

    public func increment(cardId: String, step: Int = 1) {
        var owned = ownedCards[cardId] ?? OwnedCard(cardId: cardId, quantity: 0)
        owned.quantity = max(owned.quantity + step, 0)
        owned.lastUpdated = Date()
        if owned.quantity == 0 {
            ownedCards[cardId] = nil
        } else {
            ownedCards[cardId] = owned
        }
        persist()
    }

    public func updateNotes(for cardId: String, notes: String?) {
        guard var owned = ownedCards[cardId] else { return }
        owned.notes = notes
        owned.lastUpdated = Date()
        ownedCards[cardId] = owned
        persist()
    }

    public func reset() {
        ownedCards.removeAll()
        persist()
    }

    private func persist() {
        do {
            try persistence.save(Array(ownedCards.values))
        } catch {
            assertionFailure("Failed to persist owned cards: \(error)")
        }
    }

    private func loadFromDisk() {
        do {
            let cards = try persistence.load()
            ownedCards = Dictionary(uniqueKeysWithValues: cards.map { ($0.cardId, $0) })
        } catch {
            ownedCards = [:]
        }
    }
}
