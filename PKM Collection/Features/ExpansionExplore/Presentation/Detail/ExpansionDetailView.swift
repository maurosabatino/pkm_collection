//
//  ExpansionDetailView.swift
//  PKM Collection
//
//  Created by Mauro on 03/06/25.
//
import SwiftUI
import Kingfisher

// MARK: - ExpansionDetailView

struct ExpansionDetailView: View {
    let expansion: Expansion
    @StateObject private var cardListStore: CardListStore 

    init(expansion: Expansion) {
        self.expansion = expansion
        _cardListStore = StateObject(wrappedValue: CardListStore(expansionPath: expansion.path))
    }

    var body: some View {
        VStack {
            Text("Dettagli Espansione: \(expansion.name)")
                .font(.largeTitle)
                .padding()

            if cardListStore.isLoading {
                ProgressView("Caricamento carte...")
            } else if let error = cardListStore.error {
                Text("Errore nel caricamento delle carte: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else if cardListStore.cards.isEmpty {
                ContentUnavailableView("Nessuna carta trovata", systemImage: "tray.fill", description: Text("Controlla il file JSON o la logica di caricamento."))
            } else {

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                        ForEach(cardListStore.cards) { card in
                            VStack {
                                Text(card.name)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .padding(5)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(5)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(expansion.name)
        .onAppear {
            // Avvia il caricamento delle carte quando la vista appare
            Task {
                await cardListStore.loadCards()
            }
        }
    }
}
