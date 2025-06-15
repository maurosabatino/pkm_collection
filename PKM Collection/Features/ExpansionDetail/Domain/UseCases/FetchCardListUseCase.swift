//
//  FetchCardListUseCase.swift
//  PKM Collection
//
//  Created by Mauro on 15/06/25.
//

protocol FetchCardListUseCase {
    func execute(path: String) async throws -> [CardData]
}

final class FetchCardListUseCaseImpl: FetchCardListUseCase {
    private let reposiroty: CardListRepository
    
    init(reposiroty: CardListRepository) {
        self.reposiroty = reposiroty
    }
    
    func execute(path: String) async throws -> [CardData] {
        do {
            let carList: [CardData] = try await reposiroty.fetchCardList(path: path)
            return carList
        } catch {
            throw error
        }
    }
}
