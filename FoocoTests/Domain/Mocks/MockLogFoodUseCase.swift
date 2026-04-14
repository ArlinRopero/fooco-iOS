// MARK: - MockLogFoodUseCase.swift
//
// Mock de LogFoodUseCaseProtocol para tests de ViewModels.
//
// Patrón Spy + Stub:
//   Spy  → registra cuántas veces se llamó y con qué parámetros
//   Stub → permite simular éxito o fallo configurable

import Foundation
@testable import Fooco

final class MockLogFoodUseCase: LogFoodUseCaseProtocol, @unchecked Sendable {

    // MARK: - Configuración (Stub)

    /// Error que lanzará `execute` si está configurado.
    var errorToThrow: Error?

    // MARK: - Registro (Spy)

    private(set) var callCount = 0
    private(set) var lastFood: Food?
    private(set) var lastGrams: Double?

    // MARK: - LogFoodUseCaseProtocol

    func execute(food: Food, grams: Double) async throws {
        callCount += 1
        lastFood = food
        lastGrams = grams

        if let error = errorToThrow { throw error }
    }
}
