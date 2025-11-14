//
//  Expansion.swift
//  PKM Collection
//
//  Created by Mauro on 12/06/25.
//

import Foundation

// MARK: - NumInfo

public struct NumInfo: Decodable, Hashable, Identifiable {
    public let id: UUID = UUID()
    
    public let master: Int
    public let regular: Int

   public init(from decoder: Decoder) throws {
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
    
    public init(master: Int, regular: Int) {
        self.master = master
        self.regular = regular
    }
}

// MARK: - Expansion Entity

public struct Expansion: Decodable, Identifiable, Hashable {
    public let id: String
    public let series: String
    public let path: String
    public let name: String
    public let num: NumInfo
    public let hash: String
    public let abbr: String
    public let releaseDate: Date
    public let symbolUrl: String
    public let logoUrl: String

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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.series = try container.decode(String.self, forKey: .series)
        self.path = try container.decode(String.self, forKey: .path)

        self.name = try container.decode(String.self, forKey: .name)

        self.num = try container.decode(NumInfo.self, forKey: .num)
        self.hash = try container.decode(String.self, forKey: .hash)
        self.abbr = try container.decode(String.self, forKey: .abbr)
        self.releaseDate = try container.decode(Date.self, forKey: .releaseDate)
        self.symbolUrl = try container.decode(String.self, forKey: .symbolUrl)
        self.logoUrl = try container.decode(String.self, forKey: .logoUrl)
    }

    public init(
        id: String,
        series: String,
        path: String,
        name: String,
        num: NumInfo,
        hash: String,
        abbr: String,
        releaseDate: Date,
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
