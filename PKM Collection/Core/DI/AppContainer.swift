import Foundation

final class AppContainer {
    
    private let apiclient: APIClient
    
    init() {
        self.apiclient = APIClient.shared
    }
    
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
}
