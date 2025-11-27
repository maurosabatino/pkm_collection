import SwiftUI
import CoreModels
import Persistence
import UIComponents

struct ParsedDeckCard: Equatable {
    let name: String
    let quantity: Int
    let setCode: String
    let number: String

    var cardId: String {
        "\(setCode.lowercased())-\(number)"
    }
}

struct DeckImportResult: Equatable {
    let cards: [ParsedDeckCard]
    let totalCount: Int
}

enum DeckImportParser {
    static func parse(_ text: String) -> DeckImportResult {
        var cards: [ParsedDeckCard] = []
        let lines = text.components(separatedBy: .newlines)
        let pattern = #"^\s*(\d+)\s+(.+?)\s+([A-Za-z0-9]+)\s+([0-9]+)\s*$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let headerRegex = try? NSRegularExpression(pattern: #"^[A-Za-zÀ-ÿ]+:\s*\d+"#)

        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            guard line.isEmpty == false else { continue }

            if
                let headerRegex,
                headerRegex.firstMatch(in: line, range: NSRange(location: 0, length: line.utf16.count)) != nil
            {
                continue
            }

            if
                let regex,
                let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: line.utf16.count)),
                match.numberOfRanges == 5,
                let qtyRange = Range(match.range(at: 1), in: line),
                let nameRange = Range(match.range(at: 2), in: line),
                let setRange = Range(match.range(at: 3), in: line),
                let numRange = Range(match.range(at: 4), in: line),
                let qty = Int(line[qtyRange])
            {
                let name = String(line[nameRange])
                let setCode = String(line[setRange])
                let number = String(line[numRange])
                let card = ParsedDeckCard(name: name, quantity: qty, setCode: setCode, number: number)
                cards.append(card)
            }
        }

        let total = cards.reduce(0) { $0 + $1.quantity }
        return DeckImportResult(cards: cards, totalCount: total)
    }
}

public struct DeckImportView: View {
    @ObservedObject var deckStore: DeckStore
    @ObservedObject var ownedCardsStore: OwnedCardsStore
    private let resolver: DeckCardResolver = .init()
    private let onImported: (String) -> Void

    @State private var deckName: String = ""
    @State private var deckText: String = ""
    @State private var parseResult: DeckImportResult = .init(cards: [], totalCount: 0)
    @State private var resolved: [ResolvedImportCard] = []
    @State private var isResolving = false
    @Environment(\.dismiss) private var dismiss

    public init(deckStore: DeckStore, ownedCardsStore: OwnedCardsStore, onImported: @escaping (String) -> Void = { _ in }) {
        self.deckStore = deckStore
        self.ownedCardsStore = ownedCardsStore
        self.onImported = onImported
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Importa mazzo")
                .font(.title2.weight(.semibold))

            TextField("Nome mazzo", text: $deckName)
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $deckText)
                .frame(minHeight: 200)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                .onChange(of: deckText) { newValue in
                    parseResult = DeckImportParser.parse(newValue)
                    Task { await resolveCards() }
                }

            HStack {
                Text("Carte trovate: \(parseResult.cards.count) • Totale copie: \(parseResult.totalCount)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Button(isResolving ? "Risoluzione..." : "Importa", action: importDeck)
                .buttonStyle(.borderedProminent)
                .disabled(parseResult.cards.isEmpty || deckName.isEmpty || isResolving)
            }

            if parseResult.cards.isEmpty == false {
                List(resolved.isEmpty ? parseResult.cards.map { ResolvedImportCard(parsed: $0, resolvedId: nil, card: nil) } : resolved, id: \ .id) { card in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(card.card?.name ?? card.parsed.name)
                            Text("\(card.parsed.setCode) \(card.parsed.number)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("x\(card.parsed.quantity)")
                            .font(.headline)
                        if card.resolvedId == nil {
                            Text("Non trovata")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
            } else {
                Spacer()
            }
        }
        .padding()
    }

    private func importDeck() {
        guard parseResult.cards.isEmpty == false else { return }
        deckStore.createDeck(name: deckName)
        guard let deckId = deckStore.decks.last?.id else { return }
        for item in resolved {
            let cardId = item.resolvedId ?? item.parsed.cardId
            deckStore.add(cardId: cardId, to: deckId, quantity: item.parsed.quantity)
            if !ownedCardsStore.isOwned(cardId: cardId) && !ownedCardsStore.isWishlist(cardId: cardId) {
                ownedCardsStore.toggleWishlist(for: cardId)
            }
        }
        let importedName = deckName
        deckName = ""
        deckText = ""
        parseResult = .init(cards: [], totalCount: 0)
        resolved = []
        onImported(importedName.isEmpty ? "Mazzo importato" : importedName)
        dismiss()
    }

    @MainActor
    private func resolveCards() async {
        isResolving = true
        resolved = await resolver.resolve(parseResult.cards)
        isResolving = false
    }
}
