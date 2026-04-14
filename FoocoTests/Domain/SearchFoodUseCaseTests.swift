// MARK: - SearchFoodUseCaseTests.swift

import Testing
import Foundation
@testable import Fooco

@Suite("SearchFoodUseCase")
struct SearchFoodUseCaseTests {

    private func makeSUT(
        result: [Food] = FoodMocks.searchResults,
        error: Error? = nil
    ) -> (sut: SearchFoodUseCase, repo: MockFoodRepository) {
        let repo = MockFoodRepository()
        repo.searchResult = result
        repo.errorToThrow = error
        return (SearchFoodUseCase(repository: repo), repo)
    }

    // MARK: - Éxito

    @Test("Devuelve alimentos cuando la query es válida")
    func returnsResultsForValidQuery() async throws {
        let (sut, _) = makeSUT()

        let page = try await sut.execute(query: "aguacate")

        #expect(page.foods.count == FoodMocks.searchResults.count)
    }

    @Test("Pasa la query al repositorio sin espacios laterales")
    func trimsQueryBeforePassingToRepository() async throws {
        let (sut, repo) = makeSUT()

        _ = try await sut.execute(query: "  avocado  ")

        #expect(repo.lastSearchQuery == "avocado")
    }

    @Test("Llama al repositorio exactamente una vez")
    func callsRepositoryOnce() async throws {
        let (sut, repo) = makeSUT()

        _ = try await sut.execute(query: "pollo")

        #expect(repo.searchCallCount == 1)
    }

    @Test("Pasa el número de página correcto al repositorio")
    func passesPageNumberToRepository() async throws {
        let (sut, repo) = makeSUT()

        _ = try await sut.execute(query: "arroz", page: 3)

        #expect(repo.lastSearchPageNumber == 3)
    }

    @Test("Usa página 1 por defecto")
    func usesPage1ByDefault() async throws {
        let (sut, repo) = makeSUT()

        _ = try await sut.execute(query: "pollo")

        #expect(repo.lastSearchPageNumber == 1)
    }

    // MARK: - Validación de query

    @Test("Lanza queryTooShort cuando la query tiene 1 carácter")
    func throwsForSingleCharQuery() async throws {
        let (sut, _) = makeSUT()

        await #expect(throws: SearchFoodError.queryTooShort(minimum: 2)) {
            _ = try await sut.execute(query: "a")
        }
    }

    @Test("Lanza queryTooShort cuando la query está vacía")
    func throwsForEmptyQuery() async throws {
        let (sut, _) = makeSUT()

        await #expect(throws: SearchFoodError.queryTooShort(minimum: 2)) {
            _ = try await sut.execute(query: "")
        }
    }

    @Test("Lanza queryTooShort cuando la query es solo espacios")
    func throwsForWhitespaceOnlyQuery() async throws {
        let (sut, _) = makeSUT()

        await #expect(throws: SearchFoodError.queryTooShort(minimum: 2)) {
            _ = try await sut.execute(query: "   ")
        }
    }

    @Test("No lanza con query de exactamente 2 caracteres")
    func acceptsTwoCharacterQuery() async throws {
        let (sut, _) = makeSUT()

        let page = try await sut.execute(query: "ab")
        #expect(page.foods.count >= 0)
    }

    // MARK: - Propagación de errores

    @Test("Propaga errores del repositorio")
    func propagatesRepositoryError() async throws {
        let (sut, _) = makeSUT(error: APIError.httpError(statusCode: 500))

        await #expect(throws: APIError.httpError(statusCode: 500)) {
            _ = try await sut.execute(query: "test")
        }
    }

    @Test("No llama al repositorio si la query es inválida")
    func doesNotCallRepositoryForInvalidQuery() async throws {
        let (sut, repo) = makeSUT()

        _ = try? await sut.execute(query: "x")

        #expect(repo.searchCallCount == 0)
    }
}
