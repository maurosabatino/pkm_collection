import SwiftUI

struct ExpansionListContent: View {
    @ObservedObject var vm: ExpansionListViewModel
    @Binding var isHeaderScrolledToTop: Bool
    
    @State private var showSearchBarAndFilters: Bool = false

    var body: some View {
        ScrollView {
            // GeometryReader per rilevare lo scroll
            GeometryReader { proxy in
                
                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
            }
            .frame(height: 0) // Non occupa spazio visibile
            // .background(Color.red) // DEBUG: Per vedere se il GeometryReader è presente

            VStack(spacing: 0) { // Questo VStack contiene la search/filter e LazyVStack
                // Sezione della barra di ricerca e dei filtri
                VStack(spacing: 10) {
                    TextField("Cerca Espansioni...", text: $vm.searchText)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "Tutti", isSelected: vm.selectedFilter == nil) {
                                vm.selectedFilter = nil
                                vm.applyFiltersAndSort()
                            }
                            FilterChip(title: "Completato", isSelected: vm.selectedFilter == "Completato") {
                                vm.selectedFilter = "Completato"
                                vm.applyFiltersAndSort()
                            }
                            FilterChip(title: "Incompleto", isSelected: vm.selectedFilter == "Incompleto") {
                                vm.selectedFilter = "Incompleto"
                                vm.applyFiltersAndSort()
                            }

                            ForEach(ExpansionListViewModel.SortOption.allCases) { option in
                                FilterChip(title: option.rawValue, isSelected: vm.sortBy == option) {
                                    vm.sortBy = option
                                    vm.applyFiltersAndSort()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .opacity(showSearchBarAndFilters ? 1 : 0)
                .offset(y: showSearchBarAndFilters ? 0 : -50)
                .animation(.easeOut(duration: 0.2), value: showSearchBarAndFilters)
                .padding(.bottom, showSearchBarAndFilters ? 10 : 0)

                // Contenuto della lista (LazyVStack)
                LazyVStack(spacing: 0) {
                    ForEach(vm.expansions) { expansion in
                        NavigationLink(value: expansion) {
                            ExpansionListRow(expansion: expansion)
                                .padding(.vertical, 5)
                                // .frame(height: 100) // DEBUG: Dai un'altezza fissa alle righe per testare
                                // .background(Color.green.opacity(0.3)) // DEBUG: Colora le righe
                        }
                    }
                }
                // .frame(minHeight: 1000) // DEBUG: Dai un'altezza minima alla LazyVStack per assicurare scroll
                // .background(Color.yellow.opacity(0.3)) // DEBUG: Colora la LazyVStack per vedere quanto spazio occupa
            } // Fine inner VStack
        } // Fine ScrollView
        .coordinateSpace(name: "scroll") // Applica lo spazio di coordinate al ScrollView
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
            print("Offset: \(offset)") // Questo dovrebbe ora aggiornarsi
            isHeaderScrolledToTop = offset >= 0
            showSearchBarAndFilters = offset < -50
        }
    }
}
