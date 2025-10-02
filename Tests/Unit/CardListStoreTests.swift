import XCTest
@testable import PKMCollection

final class CardListStoreTests: XCTestCase {
    private struct StubUseCase: FetchCardListUseCase {
        let data: [CardData]
        func execute(path: String) async throws -> [CardData] { data }
    }

    func testRegularModeReturnsSingleVariantPerCard() async {
        let baseCard = CardData(
            name: "Pikachu",
            cardType: .pokemon,
            lang: "en",
            foil: nil,
            size: .standard,
            back: .pokemon1999,
            regulationMark: nil,
            setIcon: "",
            collectorNumber: CollectorNumber(full: "25/100", numerator: "25", denominator: "100", numeric: 25),
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
            ext: Extension(tcgl: TcglExtension(cardID: "pi-regular", longFormID: "pi-regular", archetypeID: "", reldate: "2024-01-01", key: "pi")),
            images: Images(tcgl: TcglImages(tex: nil, png: ImagePaths(front: "https://example.com/pikachu.png", back: nil, foil: nil, etch: nil), jpg: nil))
        )

        var foilCard = baseCard
        foilCard = CardData(
            name: baseCard.name,
            cardType: baseCard.cardType,
            lang: baseCard.lang,
            foil: Foil(type: .rainbow, mask: .holo),
            size: baseCard.size,
            back: baseCard.back,
            regulationMark: baseCard.regulationMark,
            setIcon: baseCard.setIcon,
            collectorNumber: baseCard.collectorNumber,
            rarity: baseCard.rarity,
            stage: baseCard.stage,
            hp: baseCard.hp,
            types: baseCard.types,
            weakness: baseCard.weakness,
            resistance: baseCard.resistance,
            retreat: baseCard.retreat,
            text: baseCard.text,
            abilities: baseCard.abilities,
            rules: baseCard.rules,
            flavorText: baseCard.flavorText,
            ext: Extension(tcgl: TcglExtension(cardID: "pi-foil", longFormID: "pi-foil", archetypeID: "", reldate: "2024-01-01", key: "pi-foil")),
            images: Images(tcgl: TcglImages(tex: nil, png: ImagePaths(front: "https://example.com/pikachu-foil.png", back: nil, foil: "https://example.com/pikachu-foil.png", etch: nil), jpg: nil))
        )

        let store = await MainActor.run { CardListStore(expansionPath: "test", fetchCardListUseCase: StubUseCase(data: [baseCard, foilCard])) }
        await MainActor.run { store.allCardData = [baseCard, foilCard] }

        let displayed = await MainActor.run { store.displayedCards }
        XCTAssertEqual(displayed.count, 1)
        XCTAssertEqual(displayed.first?.id, baseCard.id)
    }

    func testSearchFiltersCards() async {
        let cards = ["Pikachu", "Charmander", "Squirtle"].enumerated().map { index, name in
            CardData(
                name: name,
                cardType: .pokemon,
                lang: "en",
                foil: nil,
                size: .standard,
                back: .pokemon1999,
                regulationMark: nil,
                setIcon: "",
                collectorNumber: CollectorNumber(full: "\(index + 1)/100", numerator: "\(index + 1)", denominator: "100", numeric: index + 1),
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
                ext: Extension(tcgl: TcglExtension(cardID: name.lowercased(), longFormID: name.lowercased(), archetypeID: "", reldate: "2024-01-01", key: name.lowercased())),
                images: Images(tcgl: TcglImages(tex: nil, png: ImagePaths(front: "https://example.com/\(name).png", back: nil, foil: nil, etch: nil), jpg: nil))
            )
        }

        let store = await MainActor.run { CardListStore(expansionPath: "test", fetchCardListUseCase: StubUseCase(data: cards)) }
        await MainActor.run {
            store.allCardData = cards
            store.searchText = "char"
        }

        let displayed = await MainActor.run { store.displayedCards }
        XCTAssertEqual(displayed.map { $0.name }, ["Charmander"])
    }
    
    func testMasterModeShowsAllVariantsSorted() async {
        let base = CardData(
            name: "Pikachu",
            cardType: .pokemon,
            lang: "en",
            foil: nil,
            size: .standard,
            back: .pokemon1999,
            regulationMark: nil,
            setIcon: "",
            collectorNumber: CollectorNumber(full: "25/100", numerator: "25", denominator: "100", numeric: 25),
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
            ext: Extension(tcgl: TcglExtension(cardID: "pi-regular", longFormID: "pi-regular", archetypeID: "", reldate: "2024-01-01", key: "pi")),
            images: Images(tcgl: TcglImages(tex: nil, png: ImagePaths(front: "https://example.com/pikachu.png", back: nil, foil: nil, etch: nil), jpg: nil))
        )
        let foil = CardData(
            name: "Pikachu",
            cardType: .pokemon,
            lang: "en",
            foil: Foil(type: .rainbow, mask: .holo),
            size: .standard,
            back: .pokemon1999,
            regulationMark: nil,
            setIcon: "",
            collectorNumber: CollectorNumber(full: "25/100", numerator: "25", denominator: "100", numeric: 25),
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
            ext: Extension(tcgl: TcglExtension(cardID: "pi-foil", longFormID: "pi-foil", archetypeID: "", reldate: "2024-01-01", key: "pi")),
            images: Images(tcgl: TcglImages(tex: nil, png: ImagePaths(front: "https://example.com/pikachu-foil.png", back: nil, foil: "https://example.com/pikachu-foil.png", etch: nil), jpg: nil))
        )
        let other = CardData(
            name: "Bulbasaur",
            cardType: .pokemon,
            lang: "en",
            foil: nil,
            size: .standard,
            back: .pokemon1999,
            regulationMark: nil,
            setIcon: "",
            collectorNumber: CollectorNumber(full: "10/100", numerator: "10", denominator: "100", numeric: 10),
            rarity: nil,
            stage: .basic,
            hp: 60,
            types: [.grass],
            weakness: nil,
            resistance: nil,
            retreat: 1,
            text: nil,
            abilities: nil,
            rules: nil,
            flavorText: nil,
            ext: Extension(tcgl: TcglExtension(cardID: "bu-regular", longFormID: "bu-regular", archetypeID: "", reldate: "2024-01-01", key: "bu")),
            images: Images(tcgl: TcglImages(tex: nil, png: ImagePaths(front: "https://example.com/bulbasaur.png", back: nil, foil: nil, etch: nil), jpg: nil))
        )

        let store = await MainActor.run { CardListStore(expansionPath: "test", fetchCardListUseCase: StubUseCase(data: [foil, base, other])) }
        await MainActor.run {
            store.allCardData = [foil, base, other]
            store.displayMode = .master
        }

        let displayed = await MainActor.run { store.displayedCards }
        XCTAssertEqual(displayed.map { $0.name }, ["Bulbasaur", "Pikachu", "Pikachu"]) // 10, 25, 25
    }

    func testRegularModeFallsBackWhenNoNonFoilExists() async {
        let foilOnly = CardData(
            name: "Eevee",
            cardType: .pokemon,
            lang: "en",
            foil: Foil(type: .gold, mask: .etched),
            size: .standard,
            back: .pokemon1999,
            regulationMark: nil,
            setIcon: "",
            collectorNumber: CollectorNumber(full: "5/100", numerator: "5", denominator: "100", numeric: 5),
            rarity: nil,
            stage: .basic,
            hp: 60,
            types: [.colorless],
            weakness: nil,
            resistance: nil,
            retreat: 1,
            text: nil,
            abilities: nil,
            rules: nil,
            flavorText: nil,
            ext: Extension(tcgl: TcglExtension(cardID: "ee-foil", longFormID: "ee-foil", archetypeID: "", reldate: "2024-01-01", key: "ee")),
            images: Images(tcgl: TcglImages(tex: nil, png: ImagePaths(front: "https://example.com/eevee-foil.png", back: nil, foil: "https://example.com/eevee-foil.png", etch: nil), jpg: nil))
        )

        let store = await MainActor.run { CardListStore(expansionPath: "test", fetchCardListUseCase: StubUseCase(data: [foilOnly])) }
        await MainActor.run {
            store.allCardData = [foilOnly]
            store.displayMode = .regular
        }

        let displayed = await MainActor.run { store.displayedCards }
        XCTAssertEqual(displayed.count, 1)
        XCTAssertEqual(displayed.first?.name, "Eevee")
    }

    func testSearchIsDiacriticInsensitive() async {
        let accented = CardData(
            name: "Pókémon",
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
            types: [.psychic],
            weakness: nil,
            resistance: nil,
            retreat: 1,
            text: nil,
            abilities: nil,
            rules: nil,
            flavorText: nil,
            ext: Extension(tcgl: TcglExtension(cardID: "po-1", longFormID: "po-1", archetypeID: "", reldate: "2024-01-01", key: "po")),
            images: Images(tcgl: TcglImages(tex: nil, png: ImagePaths(front: "https://example.com/pokemon.png", back: nil, foil: nil, etch: nil), jpg: nil))
        )

        let store = await MainActor.run { CardListStore(expansionPath: "test", fetchCardListUseCase: StubUseCase(data: [accented])) }
        await MainActor.run {
            store.allCardData = [accented]
            store.searchText = "pokemon" // senza accenti
        }

        let displayed = await MainActor.run { store.displayedCards }
        XCTAssertEqual(displayed.map { $0.name }, ["Pókémon"])
    }

    func testRegularModeDoesNotMixLanguagesInGrouping() async {
        let en = CardData(
            name: "Pikachu",
            cardType: .pokemon,
            lang: "en",
            foil: nil,
            size: .standard,
            back: .pokemon1999,
            regulationMark: nil,
            setIcon: "",
            collectorNumber: CollectorNumber(full: "25/100", numerator: "25", denominator: "100", numeric: 25),
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
            ext: Extension(tcgl: TcglExtension(cardID: "pi-en", longFormID: "pi-en", archetypeID: "", reldate: "2024-01-01", key: "pi")),
            images: Images(tcgl: TcglImages(tex: nil, png: ImagePaths(front: "https://example.com/pikachu-en.png", back: nil, foil: nil, etch: nil), jpg: nil))
        )
        let it = CardData(
            name: "Pikachu",
            cardType: .pokemon,
            lang: "it",
            foil: nil,
            size: .standard,
            back: .pokemon1999,
            regulationMark: nil,
            setIcon: "",
            collectorNumber: CollectorNumber(full: "25/100", numerator: "25", denominator: "100", numeric: 25),
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
            ext: Extension(tcgl: TcglExtension(cardID: "pi-it", longFormID: "pi-it", archetypeID: "", reldate: "2024-01-01", key: "pi")),
            images: Images(tcgl: TcglImages(tex: nil, png: ImagePaths(front: "https://example.com/pikachu-it.png", back: nil, foil: nil, etch: nil), jpg: nil))
        )

        let store = await MainActor.run { CardListStore(expansionPath: "test", fetchCardListUseCase: StubUseCase(data: [en, it])) }
        await MainActor.run {
            store.allCardData = [en, it]
            store.displayMode = .regular
        }

        let displayed = await MainActor.run { store.displayedCards }
        // Due voci distinte, una per lingua
        XCTAssertEqual(displayed.count, 2)
    }

    func testLoadCardsTogglesIsLoadingAndClearsErrorOnSuccess() async {
        struct SlowSuccessStub: FetchCardListUseCase {
            func execute(path: String) async throws -> [CardData] {
                try? await Task.sleep(nanoseconds: 30_000_000)
                return []
            }
        }
        let store = await MainActor.run { CardListStore(expansionPath: "x", fetchCardListUseCase: SlowSuccessStub()) }

        await MainActor.run { XCTAssertFalse(store.isLoading) }
        await MainActor.run { store.error = NSError(domain: "test", code: 1) }

        await MainActor.run {
            Task { await store.loadCards() }
        }

        // Give some time for isLoading to flip true (best-effort without expectations)
        try? await Task.sleep(nanoseconds: 5_000_000)
        await MainActor.run { XCTAssertTrue(store.isLoading) }

        // Wait for operation to complete
        try? await Task.sleep(nanoseconds: 60_000_000)
        await MainActor.run {
            XCTAssertFalse(store.isLoading)
            XCTAssertNil(store.error)
            XCTAssertTrue(store.displayedCards.isEmpty)
        }
    }

    func testLoadCardsSetsErrorOnFailure() async {
        enum StubErr: Error { case boom }
        struct FailingStub: FetchCardListUseCase {
            func execute(path: String) async throws -> [CardData] { throw StubErr.boom }
        }

        let store = await MainActor.run { CardListStore(expansionPath: "x", fetchCardListUseCase: FailingStub()) }

        await MainActor.run {
            Task { await store.loadCards() }
        }

        // Wait for operation
        try? await Task.sleep(nanoseconds: 30_000_000)
        await MainActor.run {
            XCTAssertFalse(store.isLoading)
            XCTAssertNotNil(store.error)
        }
    }
}
