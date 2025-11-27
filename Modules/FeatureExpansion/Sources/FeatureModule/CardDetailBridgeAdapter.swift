import SwiftUI
import CoreKit
import CoreModels
import Persistence

/// Adatta FullCardModalView al bridge condiviso.
public struct CardDetailBridgeAdapter: CardDetailBridge {
    public init() {}

    public func makeCardDetail(card: CardData, ownedStore: OwnedCardsStore, isPresented: Binding<Bool>) -> AnyView {
        let viewModel = CardViewModel(cardData: card)
        return AnyView(
            FullCardModalView(card: viewModel, isShowingModal: isPresented)
                .environmentObject(ownedStore)
        )
    }
}
