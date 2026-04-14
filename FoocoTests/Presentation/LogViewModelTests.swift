// MARK: - LogViewModelTests.swift

import Testing
import Foundation
@testable import Fooco

// MARK: - Mocks

private final class MockGetTodayEntriesUseCase: GetTodayEntriesUseCaseProtocol, @unchecked Sendable {
    var entries: [LogEntry] = []
    var error: Error?
    private(set) var callCount = 0

    func execute() async throws -> [LogEntry] {
        callCount += 1
        if let error { throw error }
        return entries
    }
}

private final class MockGetWeeklyEntriesUseCase: GetWeeklyEntriesUseCaseProtocol, @unchecked Sendable {
    var entries: [LogEntry] = []
    var error: Error?
    private(set) var callCount = 0

    func execute() async throws -> [LogEntry] {
        callCount += 1
        if let error { throw error }
        return entries
    }
}

// MARK: - Tests

@Suite("LogViewModel")
@MainActor
struct LogViewModelTests {

    // MARK: - Setup

    private func makeSUT(
        todayEntries: [LogEntry] = [],
        weeklyEntries: [LogEntry] = [],
        todayError: Error? = nil,
        weeklyError: Error? = nil
    ) -> (
        sut: LogViewModel,
        todayUseCase: MockGetTodayEntriesUseCase,
        weeklyUseCase: MockGetWeeklyEntriesUseCase
    ) {
        let todayUC  = MockGetTodayEntriesUseCase()
        todayUC.entries = todayEntries
        todayUC.error   = todayError

        let weeklyUC = MockGetWeeklyEntriesUseCase()
        weeklyUC.entries = weeklyEntries
        weeklyUC.error   = weeklyError

        let sut = LogViewModel(
            getTodayEntriesUseCase:  todayUC,
            getWeeklyEntriesUseCase: weeklyUC
        )
        return (sut, todayUC, weeklyUC)
    }

    private func makeEntry(
        food: Food = FoodMocks.avocado,
        grams: Double = 100,
        loggedAt: Date = Date()
    ) -> LogEntry {
        LogEntry(id: UUID(), food: food, grams: grams, loggedAt: loggedAt)
    }

    // MARK: - Estado inicial

    @Test("Estado inicial: sin registros ni loading")
    func initialState() {
        let (sut, _, _) = makeSUT()

        #expect(sut.todayEntries.isEmpty)
        #expect(sut.weeklyDays.isEmpty)
        #expect(!sut.isLoading)
        #expect(sut.errorMessage == nil)
    }

    // MARK: - load()

    @Test("load() popula todayEntries")
    func loadPopulatesTodayEntries() async throws {
        let entry = makeEntry()
        let (sut, _, _) = makeSUT(todayEntries: [entry])

        await sut.load()

        #expect(sut.todayEntries.count == 1)
        #expect(sut.todayEntries.first?.id == entry.id)
    }

    @Test("load() llama a ambos use cases en paralelo")
    func loadCallsBothUseCases() async {
        let (sut, todayUC, weeklyUC) = makeSUT()

        await sut.load()

        #expect(todayUC.callCount == 1)
        #expect(weeklyUC.callCount == 1)
    }

    @Test("load() agrupa registros semanales por día")
    func loadGroupsWeeklyEntriesByDay() async {
        let calendar = Calendar.current
        let today     = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let entryToday1     = makeEntry(loggedAt: today)
        let entryToday2     = makeEntry(loggedAt: today.addingTimeInterval(-3600))
        let entryYesterday  = makeEntry(loggedAt: yesterday)

        let (sut, _, _) = makeSUT(weeklyEntries: [entryToday1, entryToday2, entryYesterday])

        await sut.load()

        #expect(sut.weeklyDays.count == 2)

        let todayDay = sut.weeklyDays.first(where: { calendar.isDateInToday($0.date) })
        #expect(todayDay?.entries.count == 2)
    }

    @Test("load() ordena los días del más reciente al más antiguo")
    func loadSortsDaysNewestFirst() async {
        let calendar = Calendar.current
        let today     = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDays   = calendar.date(byAdding: .day, value: -2, to: today)!

        let entries = [makeEntry(loggedAt: yesterday), makeEntry(loggedAt: twoDays), makeEntry(loggedAt: today)]
        let (sut, _, _) = makeSUT(weeklyEntries: entries)

        await sut.load()

        guard sut.weeklyDays.count == 3 else { return }
        #expect(sut.weeklyDays[0].date >= sut.weeklyDays[1].date)
        #expect(sut.weeklyDays[1].date >= sut.weeklyDays[2].date)
    }

    // MARK: - Totales de hoy

    @Test("Calcula calorías totales de hoy correctamente")
    func calculatesTodayCalories() async {
        let entry1 = makeEntry(food: FoodMocks.avocado, grams: 100) // 160 kcal
        let entry2 = makeEntry(food: FoodMocks.avocado, grams: 50)  // 80 kcal
        let (sut, _, _) = makeSUT(todayEntries: [entry1, entry2])

        await sut.load()

        #expect(sut.todayCalories == 240.0)
    }

    @Test("Totales son 0 cuando no hay registros")
    func zeroTotalsWhenEmpty() async {
        let (sut, _, _) = makeSUT()

        await sut.load()

        #expect(sut.todayCalories == 0)
        #expect(sut.todayProtein  == 0)
        #expect(sut.todayCarbs    == 0)
        #expect(sut.todayFat      == 0)
    }

    // MARK: - Error handling

    @Test("Error del today use case se expone en errorMessage")
    func todayErrorSetsErrorMessage() async {
        let (sut, _, _) = makeSUT(todayError: URLError(.notConnectedToInternet))

        await sut.load()

        #expect(sut.errorMessage != nil)
    }

    @Test("Error del weekly use case se expone en errorMessage")
    func weeklyErrorSetsErrorMessage() async {
        let (sut, _, _) = makeSUT(weeklyError: URLError(.notConnectedToInternet))

        await sut.load()

        #expect(sut.errorMessage != nil)
    }

    @Test("isLoading es false al terminar la carga")
    func isLoadingFalseAfterLoad() async {
        let (sut, _, _) = makeSUT()

        await sut.load()

        #expect(!sut.isLoading)
    }
}
