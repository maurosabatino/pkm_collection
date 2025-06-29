import SwiftUI

struct ExpansionListView: View {
    @StateObject var vm: ExpansionListViewModel = .init()
    
    // Stato per la CustomHeaderView (se usata)
    @State private var isHeaderScrolledToTop: Bool = true

    var body: some View {
        NavigationStack {
            VStack {
                if vm.isLoading {
                    ProgressView("Caricamento...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Passiamo il binding per lo stato dello scroll
                    ExpansionListContent(vm: vm, isHeaderScrolledToTop: $isHeaderScrolledToTop)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // Usa la tua CustomHeaderView per il titolo animato
                    CustomHeaderView(
                        title: "Espansioni",
                        imageName: TabItem.expansions.systemImage,
                        imageColor: .orange,
                        isScrolledToTop: $isHeaderScrolledToTop
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline) // Fondamentale per CustomHeaderView
            .navigationDestination(for: Expansion.self) { expansion in
                ExpansionDetailView(expansion: expansion)
            }
        }
        .task {
            await vm.load()
        }
        .onChange(of: vm.selectedLanguage) { _ in
            Task { await vm.load() }
        }
    }
}
