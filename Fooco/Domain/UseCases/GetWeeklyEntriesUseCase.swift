// MARK: - GetWeeklyEntriesUseCase.swift
//
// UseCase para obtener los registros de los últimos 7 días (incluyendo hoy).
//
// ¿Por qué devuelve [LogEntry] y no [DailyLog]?
// El UseCase retorna datos puros del dominio.
// La agrupación por día es una decisión de presentación —
// el ViewModel la hace según cómo quiere mostrarlo.

import Foundation

// MARK: - GetWeeklyEntriesUseCaseProtocol

protocol GetWeeklyEntriesUseCaseProtocol: Sendable {
    func execute() async throws -> [LogEntry]
}

// MARK: - GetWeeklyEntriesUseCase

struct GetWeeklyEntriesUseCase: GetWeeklyEntriesUseCaseProtocol {

    private let repository: any FoodLogRepositoryProtocol

    init(repository: any FoodLogRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [LogEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Últimos 7 días: hoy + 6 días previos
        guard let weekStart = calendar.date(byAdding: .day, value: -6, to: today),
              let weekEnd   = calendar.date(byAdding: .day, value: 1, to: today)
        else { return [] }

        return try await repository.getEntries(from: weekStart, to: weekEnd)
    }
}
