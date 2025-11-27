import SwiftUI
import Persistence
import CoreModels
import CoreKit
import UIComponents

public struct WishlistDetailView: View {
    let wishlist: Wishlist
    @ObservedObject var store: WishlistStore
    @State private var cardIdInput: String = ""
    @State private var quantityInput: String = "1"

    public init(wishlist: Wishlist, store: WishlistStore) {
        self.wishlist = wishlist
        self.store = store
    }

    public var body: some View {
        List {
            Section("Carte") {
                ForEach(cards) { item in
                    HStack {
                        Text(item.cardId)
                        Spacer()
                        Text("x\(item.quantity)")
                            .foregroundColor(AppColors.textSecondary)
                            .font(.caption)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            store.add(cardId: item.cardId, to: wishlist.id, quantity: 1)
                        } label: {
                            Label("Aggiungi", systemImage: "plus")
                        }
                        .tint(.green)

                        Button(role: .destructive) {
                            store.remove(cardId: item.cardId, from: wishlist.id)
                        } label: {
                            Label("Rimuovi", systemImage: "trash")
                        }
                    }
                }
            }

            Section("Aggiungi carta") {
                HStack {
                    TextField("Card ID", text: $cardIdInput)
                    TextField("Qty", text: $quantityInput)
                        .keyboardType(.numberPad)
                        .frame(width: 60)
                    Button("Add") {
                        guard let qty = Int(quantityInput), !cardIdInput.isEmpty else { return }
                        store.add(cardId: cardIdInput, to: wishlist.id, quantity: qty)
                        cardIdInput = ""
                        quantityInput = "1"
                    }
                }
            }
        }
        .navigationTitle(wishlist.name)
    }

    private var cards: [WishlistItem] {
        store.items[wishlist.id] ?? []
    }
}
