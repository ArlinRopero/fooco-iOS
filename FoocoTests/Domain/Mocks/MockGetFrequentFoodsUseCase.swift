// MARK: - MockGetFrequentFoodsUseCase.swift
//
// Mock de GetFrequentFoodsUseCaseProtocol para tests de ViewModels.
//
// Patrón Spy + Stub:
//   Spy  → registra cuántas veces se llamó y con qué límite
//   Stub → devuelve lista configurable o lanza error

import Foundation
@testable import Fooco

final class MockGetFrequentFoodsUseCase: GetFrequentFoodsUseCaseProtocol, @unchecked Sendable {

    // MARK: - Configuración (Stub)

    /// Alimentos que devolverá `execute`. Default: lista de FoodMocks.
    var result: [Food] = FoodMocks.searchResults

    /// Error que lanzará `execute` si está configurado.
    var errorToThrow: Error?

    // MARK: - Registro (Spy)

    private(set) var callCount = 0
    private(set) var lastLimit: Int?

    // MARK: - GetFrequentFoodsUseCaseProtocol

    func execute(limit: Int) async throws -> [Food] {
        callCount += 1
        lastLimit = limit

        if let error = errorToThrow { throw error }
        return result
    }
}
