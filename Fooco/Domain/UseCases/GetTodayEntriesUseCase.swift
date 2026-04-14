// MARK: - GetTodayEntriesUseCase.swift
//
// UseCase para obtener los registros del día de hoy.
//
// Responsabilidad única: delegar al repositorio y devolver
// los LogEntry del día actual ordenados del más reciente al más antiguo.
// La lógica de calcular "hoy" vive aquí, no en el repositorio,
// porque es una regla de negocio (cuándo empieza el "día").

import Foundation

// MARK: - GetTodayEntriesUseCaseProtocol

protocol GetTodayEntriesUseCaseProtocol: Sendable {
    func execute() async throws -> [LogEntry]
}

// MARK: - GetTodayEntriesUseCase

struct GetTodayEntriesUseCase: GetTodayEntriesUseCaseProtocol {

    private let repository: any FoodLogRepositoryProtocol

    init(repository: any FoodLogRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [LogEntry] {
        try await repository.getTodayEntries()
    }
}
