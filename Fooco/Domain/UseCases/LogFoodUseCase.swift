// MARK: - LogFoodUseCase.swift
//
// UseCase para registrar un alimento en el diario del día.
//
// Responsabilidad única: validar los datos y delegar al repositorio.
// No sabe cómo se persiste — eso es cosa del repositorio.

import Foundation

// MARK: - LogFoodUseCaseProtocol

protocol LogFoodUseCaseProtocol: Sendable {
    func execute(food: Food, grams: Double) async throws
}

// MARK: - LogFoodUseCase

struct LogFoodUseCase: LogFoodUseCaseProtocol {

    private let repository: any FoodLogRepositoryProtocol

    init(repository: any FoodLogRepositoryProtocol) {
        self.repository = repository
    }

    func execute(food: Food, grams: Double) async throws {
        guard grams > 0 else { throw LogFoodError.invalidGrams }
        try await repository.logFood(food, grams: grams)
    }
}

// MARK: - LogFoodError

enum LogFoodError: Error, LocalizedError {
    case invalidGrams

    var errorDescription: String? {
        switch self {
        case .invalidGrams:
            return localized(StringKey.Log.errorInvalidGrams)
        }
    }
}
