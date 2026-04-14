// MARK: - GetTodayEntriesUseCaseTests.swift

import Testing
import Foundation
@testable import Fooco

@Suite("GetTodayEntriesUseCase")
struct GetTodayEntriesUseCaseTests {

    // MARK: - Setup

    private func makeSUT(
        todayEntries: [LogEntry] = [],
        errorToThrow: Error? = nil
    ) -> (sut: GetTodayEntriesUseCase, repo: MockFoodLogRepository) {
        let repo = MockFoodLogRepository()
        repo.todayEntriesToReturn = todayEntries
        repo.errorToThrow = errorToThrow
        let sut = GetTodayEntriesUseCase(repository: repo)
        return (sut, repo)
    }

    // MARK: - Tests

    @Test("Devuelve los registros de hoy del repositorio")
    func returnsEntriesFromRepository() async throws {
        let entry = LogEntry(
            id: UUID(),
            food: FoodMocks.avocado,
            grams: 100,
            loggedAt: Date()
        )
        let (sut, _) = makeSUT(todayEntries: [entry])

        let result = try await sut.execute()

        #expect(result.count == 1)
        #expect(result.first?.id == entry.id)
    }

    @Test("Devuelve array vacío si no hay registros hoy")
    func returnsEmptyWhenNoEntries() async throws {
        let (sut, _) = makeSUT(todayEntries: [])

        let result = try await sut.execute()

        #expect(result.isEmpty)
    }

    @Test("Propaga el error del repositorio")
    func propagatesRepositoryError() async throws {
        let (sut, _) = makeSUT(errorToThrow: URLError(.notConnectedToInternet))

        await #expect(throws: (any Error).self) {
            try await sut.execute()
        }
    }

    @Test("Llama a getTodayEntries exactamente una vez")
    func callsGetTodayEntriesOnce() async throws {
        let (sut, repo) = makeSUT()

        _ = try await sut.execute()

        #expect(repo.getTodayCallCount == 1)
    }
}
