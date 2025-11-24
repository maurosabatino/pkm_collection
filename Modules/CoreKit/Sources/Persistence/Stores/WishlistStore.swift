import Foundation

@MainActor
public final class WishlistStore: ObservableObject {
    @Published public private(set) var wishlists: [Wishlist] = []
    @Published public private(set) var items: [String: [WishlistItem]] = [:] // keyed by wishlistId

    private let wishlistDAO: WishlistDAO?
    private let wishlistItemDAO: WishlistItemDAO?

    public init(
        wishlistDAO: WishlistDAO? = WishlistDAO(),
        wishlistItemDAO: WishlistItemDAO? = WishlistItemDAO()
    ) {
        self.wishlistDAO = wishlistDAO
        self.wishlistItemDAO = wishlistItemDAO
        load()
    }

    private func load() {
        wishlists = (try? wishlistDAO?.fetchAll()) ?? []
        var map: [String: [WishlistItem]] = [:]
        for list in wishlists {
            let itemsForList = (try? wishlistItemDAO?.items(for: list.id)) ?? []
            map[list.id] = itemsForList
        }
        items = map
    }

    public func createWishlist(name: String, notes: String? = nil) {
        guard let wishlistDAO else { return }
        let wishlist = Wishlist(name: name, notes: notes)
        wishlists.append(wishlist)
        do {
            try wishlistDAO.save(wishlist)
        } catch {
            assertionFailure("Failed to save wishlist: \(error)")
        }
    }

    public func add(cardId: String, to wishlistId: String, quantity: Int = 1) {
        guard let wishlistItemDAO else { return }
        var entry = items[wishlistId] ?? []
        if let index = entry.firstIndex(where: { $0.cardId == cardId }) {
            var item = entry[index]
            item.quantity += quantity
            item.updatedAt = Date()
            entry[index] = item
            do { try wishlistItemDAO.upsert(item) } catch { assertionFailure("Failed to upsert wishlist item: \(error)") }
        } else {
            let item = WishlistItem(wishlistId: wishlistId, cardId: cardId, quantity: quantity)
            entry.append(item)
            do { try wishlistItemDAO.upsert(item) } catch { assertionFailure("Failed to upsert wishlist item: \(error)") }
        }
        items[wishlistId] = entry
    }

    public func remove(cardId: String, from wishlistId: String) {
        guard let wishlistItemDAO else { return }
        var entry = items[wishlistId] ?? []
        entry.removeAll { $0.cardId == cardId }
        items[wishlistId] = entry
        do { try wishlistItemDAO.delete(wishlistId: wishlistId, cardId: cardId) } catch {
            assertionFailure("Failed to delete wishlist item: \(error)")
        }
    }
}
