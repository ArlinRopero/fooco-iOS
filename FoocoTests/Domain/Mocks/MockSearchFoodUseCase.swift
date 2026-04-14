// MARK: - MockSearchFoodUseCase.swift

import Foundation
@testable import Fooco

final class MockSearchFoodUseCase: SearchFoodUseCaseProtocol, @unchecked Sendable {

    /// Página que devuelve. Default: página 1/1 con FoodMocks.searchResults.
    var page: FoodSearchPage = FoodSearchPage(
        foods:       FoodMocks.searchResults,
        currentPage: 1,
        totalPages:  1
    )
    var errorToThrow: Error?

    private(set) var callCount = 0
    private(set) var lastQuery: String?
    private(set) var lastPage: Int?

    func execute(query: String, page requestedPage: Int) async throws -> FoodSearchPage {
        callCount += 1
        lastQuery = query
        lastPage  = requestedPage
        if let error = errorToThrow { throw error }
        return page
    }
}
