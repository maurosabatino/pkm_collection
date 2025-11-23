import XCTest
@testable import FeatureExpansion

final class FeatureExpansionTests: XCTestCase {
    func testExample() {
        // Example placeholder test to keep Tuist target valid
        XCTAssertTrue(true)
    }
}

@MainActor
final class CardCatalogStoreTests: XCTestCase {
    func test_filtersAndSorting_appliedOnDisplayedCards() {
        let preferences = InMemoryPreferences()
        let store = CardCatalogStore(
            fetchCardListUseCase: FetchCardListUseCaseMock(),
            preferencesStorage: preferences
        )

        let olderExpansion = makeExpansion(key: "old", name: "Old Set", daysFromNow: -10)
        let newerExpansion = makeExpansion(key: "new", name: "New Set", daysFromNow: 10)

        let commonCard = makeCard(name: "Common", rarity: .common, collectorNumber: 1, types: [.fire], id: "c1")
        let rareCard = makeCard(name: "Rare", rarity: .rareUltra, collectorNumber: 2, types: [.water], id: "c2")

        store.applySample(cards: [commonCard, rareCard], expansions: [olderExpansion, newerExpansion])

        store.selectedRarities = [ .rareUltra ]
        store.selectedExpansions = [ newerExpansion.path ]
        store.sortOption = .releaseDate

        XCTAssertEqual(store.displayedCards.map(\.name), ["Rare"])
        XCTAssertEqual(store.displayedCards.first?.expansionPath, newerExpansion.path)
    }

    func test_preferences_arePersistedWhenStateChanges() {
        let preferences = InMemoryPreferences()
        let store = CardCatalogStore(
            fetchCardListUseCase: FetchCardListUseCaseMock(),
            preferencesStorage: preferences
        )

        let expansion = makeExpansion(key: "set1", name: "Set 1", daysFromNow: 0)
        store.applySample(cards: [makeCard(name: "Pikachu", rarity: .common, collectorNumber: 1, types: [.lightning], id: "pk1")], expansions: [expansion])

        store.searchText = "pi"
        store.toggleType(.lightning)
        store.toggleExpansion(path: expansion.path)
        store.setSortOption(.name)
        store.persistViewPreferences(showOwnedOnly: true, displayMode: .master)

        guard let saved = preferences.stored else {
            XCTFail("Preferences should be saved")
            return
        }

        XCTAssertEqual(saved.searchText, "pi")
        XCTAssertTrue(saved.selectedPokemonTypes.contains(PokemonType.lightning.rawValue))
        XCTAssertEqual(saved.selectedExpansions, [expansion.path])
        XCTAssertEqual(saved.sortOption, CardSortOption.name.rawValue)
        XCTAssertTrue(saved.showOwnedOnly)
        XCTAssertEqual(saved.displayMode, CardDisplayMode.master.rawValue)
    }

    // MARK: - Helpers

    private func makeCard(
        name: String,
        rarity: Designation,
        collectorNumber: Int,
        types: [PokemonType],
        id: String
    ) -> CardData {
        CardData(
            name: name,
            cardType: .pokemon,
            lang: "en",
            foil: nil,
            size: .standard,
            back: .pokemon1999,
            regulationMark: nil,
            setIcon: "",
            collectorNumber: CollectorNumber(full: "\(collectorNumber)/100", numerator: "\(collectorNumber)", denominator: "100", numeric: collectorNumber),
            rarity: Rarity(designation: rarity, icon: .solidStar),
            stage: .basic,
            hp: 60,
            types: types,
            weakness: nil,
            resistance: nil,
            retreat: 1,
            text: nil,
            abilities: nil,
            rules: nil,
            flavorText: nil,
            ext: Extension(tcgl: TcglExtension(cardID: id, longFormID: id, archetypeID: id, reldate: "2024-01-01", key: id)),
            images: Images(
                tcgl: TcglImages(
                    tex: nil,
                    png: nil,
                    jpg: nil
                )
            )
        )
    }

    private func makeExpansion(key: String, name: String, daysFromNow: Int) -> Expansion {
        Expansion(
            id: key,
            series: "Series",
            path: key,
            name: name,
            num: NumInfo(master: 1, regular: 1),
            hash: "hash",
            abbr: "ABR",
            releaseDate: Calendar.current.date(byAdding: .day, value: daysFromNow, to: Date()) ?? Date(),
            symbolUrl: "symbol",
            logoUrl: "logo"
        )
    }
}

private final class InMemoryPreferences: CardCatalogPreferencesPersisting {
    var stored: CardCatalogPreferences?

    func load() -> CardCatalogPreferences? { stored }

    func save(_ preferences: CardCatalogPreferences) {
        stored = preferences
    }
}

private struct FetchCardListUseCaseMock: FetchCardListUseCase {
    func execute(path: String) async throws -> [CardData] {
        []
    }
}
