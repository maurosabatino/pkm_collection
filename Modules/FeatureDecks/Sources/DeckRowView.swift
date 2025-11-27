import SwiftUI
import CoreModels

struct DeckRowView: View {
    let deck: Deck
    let cardCount: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(deck.name)
                    .font(.body.weight(.semibold))
                if let format = deck.format {
                    Text(format)
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
    DeckRowView(deck: Deck(id: "1", name: "Test", format: "Standard", notes: nil, updatedAt: Date(), deleted: false), cardCount: 60)
}
