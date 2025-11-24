import Foundation

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
    /// Parses a text decklist like "3 Pikachu SET 25" grouped by headers (Pokémon / Trainer / Energy).
    static func parse(_ text: String) -> DeckImportResult {
        var cards: [ParsedDeckCard] = []
        let lines = text.components(separatedBy: .newlines)
        let pattern = #"^\s*(\d+)\s+(.+?)\s+([A-Za-z0-9]+)\s+([0-9]+)\s*$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let headerRegex = try? NSRegularExpression(pattern: #"^[A-Za-zÀ-ÿ]+:\s*\d+"#)

        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            guard line.isEmpty == false else { continue }

            // Skip header lines like "Pokémon: 16"
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
