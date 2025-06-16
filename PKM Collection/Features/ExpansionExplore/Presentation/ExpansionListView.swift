import SwiftUI

struct ExpansionListView: View {
    @StateObject var vm: ExpansionListViewModel = .init()

    var body: some View {
        NavigationView {
            VStack { // <-- Qui è dove il navigationTitle dovrebbe andare
                if vm.isLoading {
                    ProgressView("Caricamento...")
                } else {
                    List(vm.expansions) { expansion in
                        NavigationLink(destination: ExpansionDetailView(expansion: expansion)) {
                            ExpansionItemView(expansion: expansion)
                                .padding(10) // Padding interno all'ExpansionItemView
                                .background(Color.white) // O un colore a tua scelta per lo sfondo della cella
                                .cornerRadius(10) // Bordi arrotondati per un effetto "card"
                                .shadow(radius: 3) // Un'ombra leggera per la profondità
                        }
                        .listRowSeparator(.hidden) // Nasconde il separatore di default della riga
                        .padding(.vertical, 5) // Padding verticale tra le righe
                    }
                    .listStyle(.inset)
                }
            }
            .navigationTitle("Espansioni") // <-- Spostato qui
        }
        .task {
            await vm.load()
        }
        .onChange(of: vm.selectedLanguage) { _ in
            Task { await vm.load() }
        }
    }
}
