import CoreKit

/// Dati equatable per una cella della griglia.
struct CardTileProps: Equatable {
    let id: String
    let name: String
    let expansionName: String?
    let foilDescription: String?
    let displayMode: CardDisplayMode
    let isOwned: Bool
    let quantity: Int
}
