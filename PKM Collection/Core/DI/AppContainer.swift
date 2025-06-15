import Foundation

final class AppContainer {
    
    private let apiclient: APIClient
    
    init() {
        self.apiclient = APIClient.shared
    }
    
    // MARK: Expansion List
    
    func makeExpansionrepository() -> ExpansionRepository {
        return DefaultExpansionRepository(fileName: "set-it-IT")
    }
    
    func makeFetchexpansionuseCase() -> FetchExpansionUseCase {
        return FetchExpansionUseCaseImpl(reposiroty: makeExpansionrepository())
    }
    
    @MainActor
    func makeExpansionListViewModel() -> ExpansionListViewModel {
        return ExpansionListViewModel(fetchExpansionUseCase: makeFetchexpansionuseCase())
    }
    
    
    // MARK: Card List
    
    func makeCardListRepository() -> CardListRepository {
        return DefaultCardListRepository()
    }
    
    func makeFetchCardListUseCase() -> FetchCardListUseCase {
        return FetchCardListUseCaseImpl(reposiroty: makeCardListRepository())
    }
    
    @MainActor
    func makeCardListViewModel(expansion: Expansion) -> ExpansionDetailViewModel {
        return ExpansionDetailViewModel(
            fetchCardListUseCase: makeFetchCardListUseCase(),
            expansion: expansion
        )
    }
   
}


