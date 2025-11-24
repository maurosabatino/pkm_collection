import Foundation

/// Wrappa una persistenza nuova e una legacy per migrare i dati al primo avvio.
public final class MigratingOwnedCardsPersistence: OwnedCardsPersistence {
    private let legacy: OwnedCardsPersistence
    private let target: OwnedCardsPersistence
    private let migrationKey = "ownedCardsMigratedToDB"

    public init(
        legacy: OwnedCardsPersistence = FileOwnedCardsPersistence(),
        target: OwnedCardsPersistence = GRDBOwnedCardsPersistence(),
        userDefaults: UserDefaults = .standard
    ) {
        self.legacy = legacy
        self.target = target
        self.userDefaults = userDefaults
    }

    private let userDefaults: UserDefaults

    public func load() throws -> [OwnedCard] {
        if !userDefaults.bool(forKey: migrationKey) {
            let legacyCards = try legacy.load()
            if !legacyCards.isEmpty {
                try target.save(legacyCards)
            }
            userDefaults.set(true, forKey: migrationKey)
            userDefaults.synchronize()
        }
        return try target.load()
    }

    public func save(_ cards: [OwnedCard]) throws {
        try target.save(cards)
    }
}
