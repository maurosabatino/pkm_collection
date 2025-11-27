import SwiftUI
import CoreModels

struct WishlistRowView: View {
    let wishlist: Wishlist
    let cardCount: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(wishlist.name)
                    .font(.body.weight(.semibold))
                if let notes = wishlist.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Text("\(cardCount) carte")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    WishlistRowView(
        wishlist: Wishlist(id: "1", name: "Test", notes: "Note", updatedAt: Date(), deleted: false),
        cardCount: 5
    )
}
