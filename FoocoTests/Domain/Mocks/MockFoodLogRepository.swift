// MARK: - MockFoodLogRepository.swift
//
// Mock de FoodLogRepositoryProtocol para tests de UseCases y ViewModels.
//
// Patrón Spy + Stub:
//   Spy  → registra qué se llamó y con qué parámetros
//   Stub → devuelve respuestas o errores configurables

import Foundation
@testable import Fooco

final class MockFoodLogRepository: FoodLogRepositoryProtocol, @unchecked Sendable {

    // MARK: - Configuración (Stub)

    /// Error que lanzará en cualquier operación (si está configurado).
    var errorToThrow: Error?

    /// Alimentos frecuentes que devolverá `getFrequentFoods`.
    var frequentFoodsToReturn: [Food] = []

    /// Entradas de hoy que devolverá `getTodayEntries`.
    var todayEntriesToReturn: [LogEntry] = []

    /// Entradas que devolverá `getEntries(from:to:)` (filtradas por rango en el mock).
    var allEntriesToReturn: [LogEntry] = []

    // MARK: - Registro (Spy)

    /// Todos los alimentos logueados con sus gramos, en orden de llamada.
    private(set) var loggedFoods: [(food: Food, grams: Double)] = []

    private(set) var logFoodCallCount = 0
    private(set) var getFrequentCallCount = 0
    private(set) var getTodayCallCount = 0
    private(set) var getEntriesCallCount = 0

    private(set) var lastLoggedFood: Food?
    private(set) var lastLoggedGrams: Double?
    private(set) var lastFrequentLimit: Int?
    private(set) var lastEntriesFrom: Date?
    private(set) var lastEntriesTo: Date?

    // MARK: - FoodLogRepositoryProtocol

    func logFood(_ food: Food, grams: Double) async throws {
        logFoodCallCount += 1
        lastLoggedFood = food
        lastLoggedGrams = grams

        if let error = errorToThrow { throw error }
        loggedFoods.append((food: food, grams: grams))
    }

    func getFrequentFoods(limit: Int) async throws -> [Food] {
        getFrequentCallCount += 1
        lastFrequentLimit = limit

        if let error = errorToThrow { throw error }
        return frequentFoodsToReturn
    }

    func getTodayEntries() async throws -> [LogEntry] {
        getTodayCallCount += 1

        if let error = errorToThrow { throw error }
        return todayEntriesToReturn
    }

    func getEntries(from startDate: Date, to endDate: Date) async throws -> [LogEntry] {
        getEntriesCallCount += 1
        lastEntriesFrom = startDate
        lastEntriesTo = endDate

        if let error = errorToThrow { throw error }
        return allEntriesToReturn.filter { $0.loggedAt >= startDate && $0.loggedAt < endDate }
    }
}
