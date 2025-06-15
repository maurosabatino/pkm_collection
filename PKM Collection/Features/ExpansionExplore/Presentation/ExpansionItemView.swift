//
//  ExpansionItemView.swift
//  PKM Collection
//
//  Created by Mauro on 15/06/25.
//

import Kingfisher
import SwiftUI

struct ExpansionItemView: View {
    let expansion: Expansion

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // MARK: - Expansion Symbol Image
            
            ExpansionLogo(urlString: expansion.logoUrl)
                .frame(width: 80, height: 80)
                .shadow(radius: 3)
            
            // MARK: - Expansion Details (Name, Abbreviation, Number of Cards)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expansion.name)
                    .font(.headline)

                
                VStack(spacing: 5) {
                    let ownedCards = 20
                    let totalCards = expansion.num.regular
                
                    ProgressView(value: Double(ownedCards), total: Double(totalCards > 0 ? totalCards : 1))
                        .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                        .frame(maxWidth: .infinity)
                    
                    Text("\(ownedCards)/\(totalCards) Carte")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            ExpansionLogo(urlString: expansion.symbolUrl)
                .frame(width: 20, height: 20)
                .shadow(radius: 3)
                .padding([.top, .trailing], 5)
                .padding(.vertical, 5)
        }
    }
}

struct ExpansionLogo: View {
    let urlString: String?

    var body: some View {
        KFImage(URL(string: urlString ?? ""))
            .resizable()
            .placeholder {
                ProgressView()
            }
            .fade(duration: 0.5)
            .scaledToFit()
            .cornerRadius(8)
    }
}

// MARK: - Preview

struct ExpansionItemView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock Expansion 1: "Scarlatto e Violetto"
        let mockExpansion1 = Expansion(
            id: "v1",
            series: "Scarlatto e Violetto",
            path: "sv1.it-IT.json",
            name: "Scarlatto & Violetto",
            num: NumInfo(master: 444, regular: 258),
            hash: "14078a7d533f8bde403c18f043f4beba",
            abbr: "SVI",
            releaseDate: "2023-03-30",
            symbolUrl: "https://pkmn-tcg-api-images.sfo2.cdn.digitaloceanspaces.com/Scarlet%20&%20Violet/symbol.png",
            logoUrl: "https://pkmn-tcg-api-images.sfo2.cdn.digitaloceanspaces.com/Scarlet%20&%20Violet/logo.png"
        )

        // Mock Expansion 2: "Crepuscolo Mascherato"
        let mockExpansion2 = Expansion(
            id: "sv6",
            series: "Scarlatto e Violetto",
            path: "sv6.it-IT.json",
            name: "Crepuscolo Mascherato",
            num: NumInfo(master: 373, regular: 226),
            hash: "f73a800036a4dc27dcd8b67863e603bc",
            abbr: "TWM",
            releaseDate: "2024-05-24",
            symbolUrl: "https://pkmn-tcg-api-images.sfo2.cdn.digitaloceanspaces.com/Twilight%20Masquerade/symbol.png",
            logoUrl: "https://pkmn-tcg-api-images.sfo2.cdn.digitaloceanspaces.com/Twilight%20Masquerade/logo.png"
        )

        // Mock Expansion 3: "Evoluzioni Prismatiche" (con num singolo)
        let mockExpansion3 = Expansion(
            id: "sv8-5",
            series: "Scarlatto e Violetto",
            path: "sv8-5.it-IT.json",
            name: "Evoluzioni Prismatiche",
            num: NumInfo(master: 447, regular: 203),
            hash: "76140a7489a6ede562f6ecee24e6db8c",
            abbr: "PRE",
            releaseDate: "2025-01-17",
            symbolUrl: "https://pkmn-tcg-api-images.sfo2.cdn.digitaloceanspaces.com/Prismatic%20Evolutions/symbol.png",
            logoUrl: "https://pkmn-tcg-api-images.sfo2.cdn.digitaloceanspaces.com/Prismatic%20Evolutions/logo.png"
        )

        List {
            ExpansionItemView(expansion: mockExpansion1)
                .previewLayout(.sizeThatFits)
                .padding()

            ExpansionItemView(expansion: mockExpansion2)
                .previewLayout(.sizeThatFits)
                .padding()

            ExpansionItemView(expansion: mockExpansion3)
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
