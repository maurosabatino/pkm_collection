//
//  CardListRepository.swift
//  PKM Collection
//
//  Created by Mauro on 15/06/25.
//

protocol CardListRepository {
    func fetchCardList(path: String) async throws -> [CardData]
}
