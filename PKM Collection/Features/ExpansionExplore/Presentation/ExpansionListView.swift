//
//  ExpansionsView.swift
//  PKM Collection
//
//  Created by Mauro on 03/06/25.
//

import SwiftUI

struct ExpansionListView: View {
    @EnvironmentObject var viewModel: ExpansionListViewModel

    var body: some View {
        NavigationView {
            VStack {

                if viewModel.isLoading {
                    ProgressView("Caricamento...")
                } else {
                    List(viewModel.expansions) { expansion in
                        NavigationLink(destination: ExpansionDetailView(expansion: expansion)) {
                            Text(expansion.name)
                        }
                    }
                }
            }
            .navigationTitle("Espansioni")
            .task {
                await viewModel.load()
            }
            .onChange(of: viewModel.selectedLanguage) { _ in
                Task { await viewModel.load() }
            }
        }
    }
}
