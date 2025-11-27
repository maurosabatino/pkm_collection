import SwiftUI
import CoreModels
import Persistence

/// Bridge per mostrare il dettaglio di una carta senza legare i moduli tra loro.
public protocol CardDetailBridge {
    func makeCardDetail(card: CardData, ownedStore: OwnedCardsStore, isPresented: Binding<Bool>) -> AnyView
}
