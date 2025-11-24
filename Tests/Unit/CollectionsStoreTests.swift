import XCTest
@testable import CoreKit
@testable import FeatureExpansion

final class CollectionsStoreTests: XCTestCase {
    // MARK: - Stores persistence

    func testWishlistStorePersistsItemsAndReloads() async throws {
        let manager = try DatabaseManager(inMemory: true)
        let store = await MainActor.run {
            WishlistStore(
                wishlistDAO: WishlistDAO(manager: manager),
                wishlistItemDAO: WishlistItemDAO(manager: manager)
            )
        }

        await MainActor.run { store.createWishlist(name: "Test Wishlist") }
        let wishlistId = await MainActor.run { store.wishlists.first?.id }
        let unwrappedWishlistId = try XCTUnwrap(wishlistId)

        await MainActor.run {
            store.add(cardId: "card-1", to: unwrappedWishlistId, quantity: 1)
            store.add(cardId: "card-1", to: unwrappedWishlistId, quantity: 2) // Update existing entry
        }

        let reloaded = await MainActor.run {
            WishlistStore(
                wishlistDAO: WishlistDAO(manager: manager),
                wishlistItemDAO: WishlistItemDAO(manager: manager)
            )
        }

        let items = await MainActor.run { reloaded.items[unwrappedWishlistId] ?? [] }
        XCTAssertEqual(items.first?.quantity, 3)
    }

    func testDeckStorePersistsCardsAndReloads() async throws {
        let manager = try DatabaseManager(inMemory: true)
        let store = await MainActor.run {
            DeckStore(
                deckDAO: DeckDAO(manager: manager),
                deckCardDAO: DeckCardDAO(manager: manager)
            )
        }

        await MainActor.run { store.createDeck(name: "Test Deck") }
        let deckId = await MainActor.run { store.decks.first?.id }
        let unwrappedDeckId = try XCTUnwrap(deckId)

        await MainActor.run {
            store.add(cardId: "card-1", to: unwrappedDeckId, quantity: 1)
            store.add(cardId: "card-1", to: unwrappedDeckId, quantity: 2) // Update existing entry
        }

        let reloaded = await MainActor.run {
            DeckStore(
                deckDAO: DeckDAO(manager: manager),
                deckCardDAO: DeckCardDAO(manager: manager)
            )
        }

        let cards = await MainActor.run { reloaded.deckCards[unwrappedDeckId] ?? [] }
        XCTAssertEqual(cards.first?.quantity, 3)
    }

    // MARK: - Database seeding from JSON fallback

    func testExpansionRepositorySeedsFromFallbackOnlyOnce() async throws {
        let manager = try DatabaseManager(inMemory: true)
        let fallback = StubExpansionRepository()
        let repository = DatabaseExpansionRepository(fallback: fallback, databaseManager: manager)

        let first = try await repository.fetchExpansions()
        let second = try await repository.fetchExpansions()

        XCTAssertEqual(fallback.fetchCount, 1)
        XCTAssertEqual(first.map(\.id), ["exp-1"])
        XCTAssertEqual(second.map(\.id), first.map(\.id))
    }

    func testCardListRepositorySeedsFromFallbackOnlyOnce() async throws {
        let manager = try DatabaseManager(inMemory: true)
        _ = try await DatabaseExpansionRepository(
            fallback: StubExpansionRepository(),
            databaseManager: manager
        ).fetchExpansions()

        let fallback = StubCardListRepository(cards: [makeCard(id: "card-1")])
        let repository = DatabaseCardListRepository(fallback: fallback, databaseManager: manager)

        let first = try await repository.fetchCardList(path: "exp-1")
        let second = try await repository.fetchCardList(path: "exp-1")

        XCTAssertEqual(fallback.fetchCount, 1)
        XCTAssertEqual(first.map(\.id), ["card-1"])
        XCTAssertEqual(second.map(\.id), first.map(\.id))
    }

    func testCardListRepositoryCreatesPlaceholderExpansionWhenMissing() async throws {
        let manager = try DatabaseManager(inMemory: true)
        let fallback = StubCardListRepository(cards: [makeCard(id: "card-1")])
        let repository = DatabaseCardListRepository(
            fallback: fallback,
            expansionRepository: StubExpansionRepository(expansions: []),
            databaseManager: manager
        )

        let cards = try await repository.fetchCardList(path: "missing-exp")
        XCTAssertEqual(cards.count, 1)

        // Verify the placeholder expansion is present and returned by DB repo.
        let expansionsFromDB = try await DatabaseExpansionRepository(
            fallback: StubExpansionRepository(expansions: []),
            databaseManager: manager
        ).fetchExpansions()
        XCTAssertEqual(expansionsFromDB.map(\.id), ["missing-exp"])
    }

    func testCardListRepositoryOverridesExpansionIdWithPathForFK() async throws {
        let manager = try DatabaseManager(inMemory: true)
        let fallbackExpansion = StubExpansionRepository(
            expansions: [
                Expansion(
                    id: "exp-base",
                    series: "Test",
                    path: "exp-base",
                    name: "Base Expansion",
                    num: NumInfo(master: 1, regular: 1),
                    hash: "hash",
                    abbr: "BASE",
                    releaseDate: Date(),
                    symbolUrl: "symbol",
                    logoUrl: "logo"
                )
            ]
        )
        let cardFallback = StubCardListRepository(cards: [makeCard(id: "card-override")])
        let repository = DatabaseCardListRepository(
            fallback: cardFallback,
            expansionRepository: fallbackExpansion,
            databaseManager: manager
        )

        let cards = try await repository.fetchCardList(path: "exp-base-it")
        XCTAssertEqual(cards.map(\.id), ["card-override"])

        // Ensure expansion with the path key exists, satisfying FK for inserted cards.
        let expansionsFromDB = try await DatabaseExpansionRepository(
            fallback: StubExpansionRepository(expansions: []),
            databaseManager: manager
        ).fetchExpansions()
        XCTAssertTrue(expansionsFromDB.contains { $0.id == "exp-base-it" })
    }

    func testCardListRepositoryDeletesConflictingExpansionIds() async throws {
        let manager = try DatabaseManager(inMemory: true)
        // Seed an expansion with base id.
        _ = try await DatabaseExpansionRepository(
            fallback: StubExpansionRepository(
                expansions: [
                    Expansion(
                        id: "exp-base",
                        series: "Test",
                        path: "exp-base",
                        name: "Base Expansion",
                        num: NumInfo(master: 1, regular: 1),
                        hash: "hash",
                        abbr: "BASE",
                        releaseDate: Date(),
                        symbolUrl: "symbol",
                        logoUrl: "logo"
                    )
                ]
            ),
            databaseManager: manager
        ).fetchExpansions()

        let repository = DatabaseCardListRepository(
            fallback: StubCardListRepository(cards: [makeCard(id: "card-override")]),
            expansionRepository: StubExpansionRepository(expansions: []),
            databaseManager: manager
        )

        // This should replace the base id with the path id and delete the old row.
        _ = try await repository.fetchCardList(path: "exp-base.it-IT")

        let expansionsFromDB = try await DatabaseExpansionRepository(
            fallback: StubExpansionRepository(expansions: []),
            databaseManager: manager
        ).fetchExpansions()
        XCTAssertEqual(Set(expansionsFromDB.map(\.id)), ["exp-base.it-IT"])
    }
}

// MARK: - Test helpers

private final class StubExpansionRepository: ExpansionRepository {
    var fetchCount = 0
    private let expansions: [Expansion]

    init(expansions: [Expansion] = [
        Expansion(
            id: "exp-1",
            series: "Test Series",
            path: "exp-1",
            name: "Expansion One",
            num: NumInfo(master: 1, regular: 1),
            hash: "hash",
            abbr: "EXP",
            releaseDate: Date(timeIntervalSince1970: 0),
            symbolUrl: "symbol",
            logoUrl: "logo"
        )
    ]) {
        self.expansions = expansions
    }

    func fetchExpansions() async throws -> [Expansion] {
        fetchCount += 1
        return expansions
    }
}

private final class StubCardListRepository: CardListRepository {
    var fetchCount = 0
    let cards: [CardData]

    init(cards: [CardData]) {
        self.cards = cards
    }

    func fetchCardList(path: String) async throws -> [CardData] {
        fetchCount += 1
        return cards
    }
}

private func makeCard(id: String) -> CardData {
    CardData(
        name: "Pikachu",
        cardType: .pokemon,
        lang: "en",
        foil: nil,
        size: .standard,
        back: .pokemon1999,
        regulationMark: nil,
        setIcon: "icon",
        collectorNumber: CollectorNumber(full: "001/001", numerator: "1", denominator: "1", numeric: 1),
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
        ext: Extension(tcgl: TcglExtension(cardID: id, longFormID: id, archetypeID: "", reldate: "2024-01-01", key: id)),
        images: nil
    )
}
