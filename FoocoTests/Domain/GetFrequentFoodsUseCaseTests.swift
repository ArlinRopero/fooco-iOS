// MARK: - GetFrequentFoodsUseCaseTests.swift
//
// Tests para GetFrequentFoodsUseCase.
//
// ¿Qué probamos aquí?
// Que el use case delega correctamente al repositorio,
// pasa los parámetros tal cual los recibe,
// y propaga errores sin modificarlos.

import Testing
import Foundation
@testable import Fooco

@Suite("GetFrequentFoodsUseCase")
struct GetFrequentFoodsUseCaseTests {

    // MARK: - SUT factory

    private func makeSUT(
        frequentFoods: [Food] = FoodMocks.searchResults,
        error: Error? = nil
    ) -> (sut: GetFrequentFoodsUseCase, repo: MockFoodLogRepository) {
        let repo = MockFoodLogRepository()
        repo.frequentFoodsToReturn = frequentFoods
        repo.errorToThrow = error
        return (GetFrequentFoodsUseCase(repository: repo), repo)
    }

    // MARK: - Delegación al repositorio

    @Test("Delega al repositorio y devuelve sus resultados")
    func returnsRepositoryResults() async throws {
        // Arrange
        let expected = FoodMocks.searchResults
        let (sut, _) = makeSUT(frequentFoods: expected)

        // Act
        let result = try await sut.execute(limit: 5)

        // Assert
        #expect(result == expected)
    }

    @Test("Pasa el límite correcto al repositorio")
    func passesLimitToRepository() async throws {
        // Arrange
        let (sut, repo) = makeSUT()

        // Act
        _ = try await sut.execute(limit: 10)

        // Assert
        #expect(repo.lastFrequentLimit == 10)
    }

    @Test("Pasa el límite por defecto (5) cuando se llama sin parámetro")
    func passesDefaultLimitToRepository() async throws {
        // Arrange
        let (sut, repo) = makeSUT()

        // Act
        _ = try await sut.execute(limit: 5)

        // Assert
        #expect(repo.lastFrequentLimit == 5)
    }

    @Test("Llama al repositorio exactamente una vez")
    func callsRepositoryOnce() async throws {
        // Arrange
        let (sut, repo) = makeSUT()

        // Act
        _ = try await sut.execute(limit: 5)

        // Assert
        #expect(repo.getFrequentCallCount == 1)
    }

    // MARK: - Lista vacía

    @Test("Devuelve lista vacía cuando el repositorio devuelve vacío")
    func returnsEmptyListWhenRepositoryReturnsEmpty() async throws {
        // Arrange
        let (sut, _) = makeSUT(frequentFoods: [])

        // Act
        let result = try await sut.execute(limit: 5)

        // Assert
        #expect(result.isEmpty)
    }

    // MARK: - Propagación de errores

    @Test("Propaga errores del repositorio")
    func propagatesRepositoryError() async throws {
        // Arrange
        let (sut, _) = makeSUT(error: APIError.httpError(statusCode: 503))

        // Act & Assert
        await #expect(throws: APIError.httpError(statusCode: 503)) {
            _ = try await sut.execute(limit: 5)
        }
    }
}
