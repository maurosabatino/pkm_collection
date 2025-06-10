//
//  ExpansionsView.swift
//  PKM Collection
//
//  Created by Mauro on 03/06/25.
//

import SwiftUI

struct ExpansionsView: View {
    @StateObject private var viewModel = ExpansionsViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Picker("Lingua", selection: $viewModel.selectedLanguage) {
                    ForEach(Language.allCases) { lang in
                        Text(lang.label).tag(lang)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                if viewModel.isLoading {
                    ProgressView("Caricamento...")
                } else {
                    List(viewModel.expansions) { expansion in
                        NavigationLink(destination: ExpansionDetailView(setInfo: expansion)) {
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
