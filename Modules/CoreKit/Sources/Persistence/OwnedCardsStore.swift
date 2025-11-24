import SwiftUI

@MainActor
public final class OwnedCardsStore: ObservableObject {
    @Published private(set) var ownedCards: [String: OwnedCard] = [:]

    private let persistence: OwnedCardsPersistence

    public init(persistence: OwnedCardsPersistence = MigratingOwnedCardsPersistence()) {
        self.persistence = persistence
        loadFromDisk()
    }

    public func isOwned(cardId: String) -> Bool {
        ownedCards[cardId]?.quantity ?? 0 > 0
    }

    public func isWishlist(cardId: String) -> Bool {
        ownedCards[cardId]?.isWishlist ?? false
    }

    public func quantity(for cardId: String) -> Int {
        ownedCards[cardId]?.quantity ?? 0
    }

    public func toggleOwnership(for cardId: String) {
        if let existing = ownedCards[cardId], existing.quantity > 0 {
            var updated = existing
            updated.quantity = 0
            ownedCards[cardId] = updated.isWishlist ? updated : nil
        } else {
            ownedCards[cardId] = OwnedCard(cardId: cardId, isWishlist: ownedCards[cardId]?.isWishlist ?? false)
        }
        persist()
    }

    public func increment(cardId: String, step: Int = 1) {
        var owned = ownedCards[cardId] ?? OwnedCard(cardId: cardId, quantity: 0, isWishlist: false)
        owned.quantity = max(owned.quantity + step, 0)
        owned.lastUpdated = Date()
        if owned.quantity == 0 {
            ownedCards[cardId] = owned.isWishlist ? OwnedCard(cardId: cardId, quantity: 0, notes: owned.notes, lastUpdated: owned.lastUpdated, isWishlist: true) : nil
        } else {
            ownedCards[cardId] = owned
        }
        persist()
    }

    public func toggleWishlist(for cardId: String) {
        var owned = ownedCards[cardId] ?? OwnedCard(cardId: cardId, quantity: 0, isWishlist: false)
        owned.isWishlist.toggle()
        owned.lastUpdated = Date()
        if owned.quantity == 0, owned.isWishlist == false {
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

    public func ownedCount(for cardIds: [String]) -> Int {
        cardIds.reduce(0) { partial, id in
            partial + ((ownedCards[id]?.quantity ?? 0) > 0 ? 1 : 0)
        }
    }

    public func wishlistCount(for cardIds: [String]) -> Int {
        cardIds.reduce(0) { partial, id in
            partial + ((ownedCards[id]?.isWishlist ?? false) ? 1 : 0)
        }
    }

    public func duplicateCount(for cardIds: [String]) -> Int {
        cardIds.reduce(0) { partial, id in
            guard let qty = ownedCards[id]?.quantity, qty > 1 else { return partial }
            return partial + (qty - 1)
        }
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
