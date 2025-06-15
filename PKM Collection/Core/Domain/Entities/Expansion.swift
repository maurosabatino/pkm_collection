//
//  Expansion.swift
//  PKM Collection
//
//  Created by Mauro on 12/06/25.
//

import Foundation

// MARK: - NumInfo

struct NumInfo: Decodable {
    let master: Int
    let regular: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self.master = intValue
            self.regular = intValue
        } else {
            let objectContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.master = try objectContainer.decode(Int.self, forKey: .master)
            self.regular = try objectContainer.decode(Int.self, forKey: .regular)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case master
        case regular
    }
    
    init( master: Int, regular: Int) {
        self.master = master
        self.regular = regular
    }
}

// MARK: - Expansion Entity

struct Expansion: Decodable, Identifiable {
    let id: String
    let series: String
    let path: String
    let name: String
    let num: NumInfo
    let hash: String
    let abbr: String
    let releaseDate: String
    let symbolUrl: String
    let logoUrl: String

    private enum CodingKeys: String, CodingKey {
        case id = "key"
        case series
        case path
        case name
        case num
        case hash
        case abbr
        case releaseDate
        case symbolUrl
        case logoUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.series = try container.decode(String.self, forKey: .series)
        self.path = try container.decode(String.self, forKey: .path)

        self.name = try container.decode(String.self, forKey: .name)

        self.num = try container.decode(NumInfo.self, forKey: .num)
        self.hash = try container.decode(String.self, forKey: .hash)
        self.abbr = try container.decode(String.self, forKey: .abbr)
        self.releaseDate = try container.decode(String.self, forKey: .releaseDate)
        self.symbolUrl = try container.decode(String.self, forKey: .symbolUrl)
        self.logoUrl = try container.decode(String.self, forKey: .logoUrl)
    }

    init(
        id: String,
        series: String,
        path: String,
        name: String,
        num: NumInfo,
        hash: String,
        abbr: String,
        releaseDate: String,
        symbolUrl: String,
        logoUrl: String
    ) {
        self.id = id
        self.series = series
        self.path = path
        self.name = name
        self.num = num
        self.hash = hash
        self.abbr = abbr
        self.releaseDate = releaseDate
        self.symbolUrl = symbolUrl
        self.logoUrl = logoUrl
    }
}
