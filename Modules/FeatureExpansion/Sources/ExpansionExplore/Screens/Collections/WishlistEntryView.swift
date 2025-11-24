import SwiftUI
import CoreKit

struct WishlistEntryView: View {
    @ObservedObject var wishlistStore: WishlistStore

    @State private var newWishlistName: String = ""

    var body: some View {
        List {
            Section("Wishlists") {
                ForEach(wishlistStore.wishlists) { wishlist in
                    NavigationLink {
                        WishlistDetailView(
                            wishlist: wishlist,
                            store: wishlistStore
                        )
                    } label: {
                        WishlistRowView(
                            wishlist: wishlist,
                            cardCount: wishlistStore.items[wishlist.id]?.reduce(0) { $0 + $1.quantity } ?? 0
                        )
                    }
                }

                HStack {
                    TextField("Nuova wishlist", text: $newWishlistName)
                    Button("Aggiungi") {
                        guard !newWishlistName.isEmpty else { return }
                        wishlistStore.createWishlist(name: newWishlistName)
                        newWishlistName = ""
                    }
                }
            }
        }
        .navigationTitle("Collection")
    }
}

#Preview {
    WishlistEntryView(
        wishlistStore: WishlistStore()
    )
}
