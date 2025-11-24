import SwiftUI
import CoreKit

struct DecksEntryView: View {
    @ObservedObject var deckStore: DeckStore
    @ObservedObject var ownedCardsStore: OwnedCardsStore

    @State private var showingImport = false
    @State private var newDeckName: String = ""

    var body: some View {
        List {
            Section("Mazzi") {
                ForEach(deckStore.decks) { deck in
                    NavigationLink {
                        DeckDetailView(
                            deck: deck,
                            store: deckStore,
                            ownedCardsStore: ownedCardsStore
                        )
                    } label: {
                        DeckRowView(
                            deck: deck,
                            cardCount: deckStore.deckCards[deck.id]?.reduce(0) { $0 + $1.quantity } ?? 0
                        )
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deckStore.deleteDeck(id: deck.id)
                        } label: {
                            Label("Elimina", systemImage: "trash")
                        }
                    }
                }

                HStack {
                    TextField("Nuovo mazzo", text: $newDeckName)
                    Button("Aggiungi") {
                        guard !newDeckName.isEmpty else { return }
                        deckStore.createDeck(name: newDeckName)
                        newDeckName = ""
                    }
                }
            }
        }
        .navigationTitle("Mazzi")
        .toolbar {
            Button {
                showingImport = true
            } label: {
                Label("Importa mazzo", systemImage: "square.and.arrow.down")
            }
        }
        .sheet(isPresented: $showingImport) {
            NavigationStack {
                DeckImportView(deckStore: deckStore, ownedCardsStore: ownedCardsStore)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Chiudi") { showingImport = false }
                        }
                    }
            }
        }
    }
}

#Preview {
    DecksEntryView(deckStore: DeckStore(), ownedCardsStore: OwnedCardsStore())
}
