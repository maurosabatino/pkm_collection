import SwiftUI
import CoreKit
import CoreModels
import Persistence

public struct DecksEntryView: View {
    @ObservedObject var deckStore: DeckStore
    @ObservedObject var ownedCardsStore: OwnedCardsStore
    private let cardDetailBridge: CardDetailBridge?

    @State private var showingImport = false
    @State private var newDeckName: String = ""
    @State private var importMessage: String?

    public init(deckStore: DeckStore, ownedCardsStore: OwnedCardsStore, cardDetailBridge: CardDetailBridge? = nil) {
        self.deckStore = deckStore
        self.ownedCardsStore = ownedCardsStore
        self.cardDetailBridge = cardDetailBridge
    }

    public var body: some View {
        List {
            Section("Mazzi") {
                ForEach(deckStore.decks) { deck in
                    NavigationLink {
                        DeckDetailView(
                            deck: deck,
                            store: deckStore,
                            ownedCardsStore: ownedCardsStore,
                            cardDetailBridge: cardDetailBridge
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
                DeckImportView(deckStore: deckStore, ownedCardsStore: ownedCardsStore) { name in
                    importMessage = "Mazzo \"\(name)\" importato"
                    showingImport = false
                }
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Chiudi") { showingImport = false }
                        }
                    }
            }
        }
        .alert(importMessage ?? "", isPresented: Binding(
            get: { importMessage != nil },
            set: { if !$0 { importMessage = nil } }
        )) {
            Button("OK", role: .cancel) { importMessage = nil }
        }
    }
}

#Preview {
    DecksEntryView(deckStore: DeckStore(), ownedCardsStore: OwnedCardsStore())
}
