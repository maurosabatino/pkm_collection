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
    @StateObject private var viewModel = ExpansionDetailViewModel()
    
    let expansion: Expansion
    
    
    init(expansion: Expansion) {
        self.expansion = expansion
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if viewModel.isLoading {
                    ProgressView("Caricamento carte...")
                } else if let error = viewModel.error {
                    Text("Errore: \(error)")
                } else {
                    if geometry.size.width < Constants.compactWidthThreshold {
                        ListView(cards: viewModel.cards)
                    } else {
                        GridView(cards: viewModel.cards, availableWidth: geometry.size.width)
                    }
                }
            }
            .navigationTitle("Carte")
            .task {
                await viewModel.load(expansion: expansion)
            }
        }
    }
}

extension ExpansionDetailView {
    enum Constants {
        static let compactWidthThreshold: CGFloat = 500
    }
}

// MARK: - ListView (Per il layout a lista)
struct ListView: View {
    let cards: [CardData]
    
    var body: some View {
        List(cards, id: \.id) { card in
            CardListRow(card: card)
        }
    }
}

// MARK: - CardListRow (Cella per la riga della List)
struct CardListRow: View {
    let card: CardData
    
    var body: some View {
        HStack {
            CardImageView(urlString: card.images?.tcgl.jpg?.front)
                .frame(width: 80, height: 110)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(card.name)
                    .font(.headline)
                Text("N° \(card.collectorNumber.full ?? "N.A.")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(card.rarity?.designation.rawValue ?? "N.A.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - GridView (Modificata per passare availableWidth a CardGridCell)
struct GridView: View {
    let cards: [CardData]
    let availableWidth: CGFloat // Larghezza fornita dal GeometryReader
    
    var body: some View {
        ScrollView {
            let minItemWidth: CGFloat = {
                if availableWidth > 1200 { return 180 }
                if availableWidth > 900 { return 150 }
                return 120
            }()
            
            let columns: [GridItem] = [
                GridItem(.adaptive(minimum: minItemWidth), spacing: 20),
                GridItem(.adaptive(minimum: minItemWidth), spacing: 20),
                GridItem(.adaptive(minimum: minItemWidth), spacing: 20)
            ]
            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(cards) { card in
                    // Passa availableWidth a CardGridCell
                    CardGridCell(card: card, availableWidth: availableWidth) // <--- MODIFICA QUI
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - CardGridCell (Modificata per dimensioni dinamiche dell'immagine)
struct CardGridCell: View {
    let card: CardData
    let availableWidth: CGFloat // Riceve la larghezza disponibile
    
    var body: some View {
        // Calcola le dimensioni dell'immagine in base alla larghezza disponibile
        let imageSize: CGSize = {
            if availableWidth > 1200 {
                // Schermi molto grandi: immagine molto più grande
                return CGSize(width: 360, height: 500) // Esempio 500/600 di altezza
            } else if availableWidth > 900 {
                // Schermi grandi: immagine più grande
                return CGSize(width: 180, height: 250)
            } else {
                // Schermi medi/piccoli: dimensione standard
                return CGSize(width: 120, height: 165)
            }
        }()
        
        VStack {
            CardImageView(urlString: card.images?.tcgl.jpg?.front)
                .frame(width: imageSize.width, height: imageSize.height) // <--- USA imageSize QUI
                .shadow(radius: 3)
            
            Text(card.name)
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 5)
        }
        .padding(.vertical, 5)
    }
}

// MARK: - CardImageView (Vista Immagine Riutilizzabile con Kingfisher)
// Estratta per evitare duplicazioni e centralizzare la logica di caricamento immagine
struct CardImageView: View {
    let urlString: String?
    
    var body: some View {
        KFImage(URL(string: urlString ?? ""))
            .resizable()
            .placeholder {
                ProgressView() // Vista mostrata durante il caricamento
            }
            .fade(duration: 0.5) // Animazione di comparsa
            .scaledToFit()
            .cornerRadius(8)
    }
}
