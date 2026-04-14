// MARK: - MockGetFoodDetailUseCase.swift

import Foundation
@testable import Fooco

final class MockGetFoodDetailUseCase: GetFoodDetailUseCaseProtocol, @unchecked Sendable {

    var result: FoodDetail = FoodDetailMocks.avocadoDetail
    var errorToThrow: Error?

    private(set) var callCount = 0
    private(set) var lastFdcId: Int?

    func execute(fdcId: Int) async throws -> FoodDetail {
        callCount += 1
        lastFdcId = fdcId
        if let error = errorToThrow { throw error }
        return result
    }
}
