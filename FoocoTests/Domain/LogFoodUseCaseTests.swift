// MARK: - LogFoodUseCaseTests.swift
//
// Tests para LogFoodUseCase.
//
// ¿Qué probamos aquí?
// Que el use case valida los gramos antes de delegar al repositorio,
// que llama al repositorio con los parámetros correctos,
// y que propaga errores del repositorio correctamente.

import Testing
import Foundation
@testable import Fooco

@Suite("LogFoodUseCase")
struct LogFoodUseCaseTests {

    // MARK: - SUT factory

    private func makeSUT(
        error: Error? = nil
    ) -> (sut: LogFoodUseCase, repo: MockFoodLogRepository) {
        let repo = MockFoodLogRepository()
        repo.errorToThrow = error
        return (LogFoodUseCase(repository: repo), repo)
    }

    // MARK: - Éxito

    @Test("Llama al repositorio con el food correcto")
    func callsRepositoryWithCorrectFood() async throws {
        // Arrange
        let (sut, repo) = makeSUT()

        // Act
        try await sut.execute(food: FoodMocks.avocado, grams: 150)

        // Assert
        #expect(repo.lastLoggedFood == FoodMocks.avocado)
    }

    @Test("Llama al repositorio con los grams correctos")
    func callsRepositoryWithCorrectGrams() async throws {
        // Arrange
        let (sut, repo) = makeSUT()

        // Act
        try await sut.execute(food: FoodMocks.avocado, grams: 150)

        // Assert
        #expect(repo.lastLoggedGrams == 150)
    }

    @Test("Llama al repositorio exactamente una vez")
    func callsRepositoryOnce() async throws {
        // Arrange
        let (sut, repo) = makeSUT()

        // Act
        try await sut.execute(food: FoodMocks.avocado, grams: 200)

        // Assert
        #expect(repo.logFoodCallCount == 1)
    }

    @Test("Grams de 0.1 es válido (justo encima del límite)")
    func acceptsMinimalPositiveGrams() async throws {
        // Arrange
        let (sut, repo) = makeSUT()

        // Act
        try await sut.execute(food: FoodMocks.apple, grams: 0.1)

        // Assert — no lanzó, repositorio fue llamado
        #expect(repo.logFoodCallCount == 1)
    }

    // MARK: - Validación de grams

    @Test("Lanza invalidGrams cuando grams es 0")
    func throwsInvalidGramsForZero() async throws {
        // Arrange
        let (sut, _) = makeSUT()

        // Act & Assert
        await #expect(throws: LogFoodError.invalidGrams) {
            try await sut.execute(food: FoodMocks.avocado, grams: 0)
        }
    }

    @Test("Lanza invalidGrams cuando grams es negativo")
    func throwsInvalidGramsForNegative() async throws {
        // Arrange
        let (sut, _) = makeSUT()

        // Act & Assert
        await #expect(throws: LogFoodError.invalidGrams) {
            try await sut.execute(food: FoodMocks.avocado, grams: -50)
        }
    }

    @Test("No llama al repositorio cuando grams es 0")
    func doesNotCallRepositoryForZeroGrams() async throws {
        // Arrange
        let (sut, repo) = makeSUT()

        // Act
        _ = try? await sut.execute(food: FoodMocks.avocado, grams: 0)

        // Assert
        #expect(repo.logFoodCallCount == 0)
    }

    @Test("No llama al repositorio cuando grams es negativo")
    func doesNotCallRepositoryForNegativeGrams() async throws {
        // Arrange
        let (sut, repo) = makeSUT()

        // Act
        _ = try? await sut.execute(food: FoodMocks.avocado, grams: -50)

        // Assert
        #expect(repo.logFoodCallCount == 0)
    }

    // MARK: - Propagación de errores

    @Test("Propaga errores del repositorio")
    func propagatesRepositoryError() async throws {
        // Arrange
        let repositoryError = APIError.httpError(statusCode: 500)
        let (sut, _) = makeSUT(error: repositoryError)

        // Act & Assert
        await #expect(throws: APIError.httpError(statusCode: 500)) {
            try await sut.execute(food: FoodMocks.avocado, grams: 100)
        }
    }
}
