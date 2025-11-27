import XCTest
@testable import FeatureDecks

final class DeckListParserTests: XCTestCase {
    func testParsesSampleList() {
        let sample = """
        Pokémon: 16
        3 Munkidori TWM 95
        2 Yveltal MEG 88
        2 Cornerstone Mask Ogerpon ex TWM 112
        2 Mega Absol ex MEG 86
        2 Mega Kangaskhan ex MEG 104
        1 Latias ex SSP 76
        1 Bloodmoon Ursaluna ex TWM 141
        1 Psyduck MEP 7
        1 Fezandipiti ex SFA 38
        1 Pecharunt ex SFA 39

        Trainer: 34
        4 Arven OBF 186
        4 Boss's Orders MEG 114
        3 Lillie's Determination MEG 119
        3 Penny SVI 183
        2 Iono PAL 185
        2 Nest Ball SVI 181
        2 Earthen Vessel PAR 163
        2 Night Stretcher SFA 61
        2 Counter Catcher PAR 160
        2 Pokégear 3.0 SVI 186
        1 Precious Trolley SSP 185
        1 Energy Switch MEG 115
        2 Bravery Charm PAL 173
        2 Technical Machine: Turbo Energize PAR 179
        2 Lively Stadium SSP 180

        Energy: 10
        6 Darkness Energy MEE 7
        2 Mist Energy TEF 161
        2 Fighting Energy MEE 6
        """

        let result = DeckImportParser.parse(sample)
        XCTAssertEqual(result.cards.count, 28)
        XCTAssertEqual(result.totalCount, 60)

        let first = result.cards.first
        XCTAssertEqual(first?.name, "Munkidori")
        XCTAssertEqual(first?.quantity, 3)
        XCTAssertEqual(first?.setCode, "TWM")
        XCTAssertEqual(first?.number, "95")
        XCTAssertEqual(first?.cardId, "twm-95")
    }

    func testSkipsInvalidLines() {
        let result = DeckImportParser.parse("""
        Pokémon: 1
        not-a-card-line
        2 MissingTokens
        """)
        XCTAssertTrue(result.cards.isEmpty)
    }
}
