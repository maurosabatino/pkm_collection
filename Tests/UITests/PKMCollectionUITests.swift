import XCTest

final class PKMCollectionUITests: XCTestCase {
    func testCanOpenExpansionDetail() {
        let app = XCUIApplication()
        app.launch()

        let expansionsList = app.collectionViews.firstMatch.exists ? app.collectionViews.firstMatch : app.tables.firstMatch
        XCTAssertTrue(expansionsList.waitForExistence(timeout: 12), "Expansions list did not appear")

        let searchField = app.searchFields.firstMatch
        if searchField.waitForExistence(timeout: 2) {
            searchField.tap()
            searchField.typeText("Paldea")
        }

        let filteredCell = expansionsList.cells.firstMatch
        XCTAssertTrue(filteredCell.waitForExistence(timeout: 5), "Filtered expansion cell not found")
    }
}
