// MARK: - GetWeeklyEntriesUseCaseTests.swift

import Testing
import Foundation
@testable import Fooco

@Suite("GetWeeklyEntriesUseCase")
struct GetWeeklyEntriesUseCaseTests {

    // MARK: - Setup

    private func makeSUT(
        entries: [LogEntry] = [],
        errorToThrow: Error? = nil
    ) -> (sut: GetWeeklyEntriesUseCase, repo: MockFoodLogRepository) {
        let repo = MockFoodLogRepository()
        repo.allEntriesToReturn = entries
        repo.errorToThrow = errorToThrow
        let sut = GetWeeklyEntriesUseCase(repository: repo)
        return (sut, repo)
    }

    // MARK: - Tests

    @Test("Devuelve registros dentro del rango de 7 días")
    func returnsEntriesWithinWeekRange() async throws {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let oldEntry  = LogEntry(id: UUID(), food: FoodMocks.avocado, grams: 100,
                                 loggedAt: calendar.date(byAdding: .day, value: -10, to: today)!)
        let thisWeek  = LogEntry(id: UUID(), food: FoodMocks.avocado, grams: 150, loggedAt: yesterday)

        let (sut, _) = makeSUT(entries: [oldEntry, thisWeek])

        let result = try await sut.execute()

        // El mock filtra por rango, así que solo devuelve registros dentro de 7 días
        #expect(result.contains { $0.id == thisWeek.id })
        #expect(!result.contains { $0.id == oldEntry.id })
    }

    @Test("Devuelve array vacío si no hay registros en la semana")
    func returnsEmptyWhenNoWeeklyEntries() async throws {
        let (sut, _) = makeSUT(entries: [])

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

    @Test("Pasa un rango de 7 días exactos al repositorio")
    func passesCorrect7DayRange() async throws {
        let (sut, repo) = makeSUT()

        _ = try await sut.execute()

        #expect(repo.getEntriesCallCount == 1)

        if let from = repo.lastEntriesFrom, let to = repo.lastEntriesTo {
            let calendar = Calendar.current
            let days = calendar.dateComponents([.day], from: from, to: to).day ?? 0
            #expect(days == 7)
        }
    }

    @Test("El rango incluye hoy como último día")
    func rangeIncludesEndOfToday() async throws {
        let (sut, repo) = makeSUT()

        _ = try await sut.execute()

        if let to = repo.lastEntriesTo {
            let calendar = Calendar.current
            // `to` es startOfDay(mañana), es decir endOfToday exclusivo
            let tomorrow = calendar.startOfDay(
                for: calendar.date(byAdding: .day, value: 1, to: Date())!
            )
            let isSameDay = calendar.isDate(to, inSameDayAs: tomorrow)
            #expect(isSameDay)
        }
    }
}
