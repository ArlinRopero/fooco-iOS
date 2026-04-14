// MARK: - FoodLogRepositoryProtocol.swift
//
// Protocolo del repositorio de registros de alimentos.
//
// ¿Por qué en Domain y no en Data?
// Domain define el contrato (qué puede hacer).
// Data provee la implementación (cómo lo hace con SwiftData).
// El UseCase depende solo del protocolo — no sabe si los datos
// viven en SQLite, CoreData, memoria, o cualquier otro lugar.

import Foundation

// MARK: - FoodLogRepositoryProtocol

/// Contrato para persistir y consultar registros de alimentos consumidos.
///
/// Las implementaciones concretas (SwiftData, InMemory para tests) deben
/// cumplir este contrato — la lógica de negocio no sabe cómo se persiste.
protocol FoodLogRepositoryProtocol: Sendable {

    /// Guarda un nuevo registro de consumo.
    ///
    /// - Parameters:
    ///   - food: Alimento consumido.
    ///   - grams: Cantidad en gramos. Debe ser > 0.
    func logFood(_ food: Food, grams: Double) async throws

    /// Devuelve los alimentos más registrados, ordenados de mayor a menor frecuencia.
    ///
    /// Útil para mostrar el historial rápido ("tus alimentos frecuentes").
    ///
    /// - Parameter limit: Máximo número de alimentos a devolver.
    func getFrequentFoods(limit: Int) async throws -> [Food]

    /// Devuelve todos los registros del día de hoy, del más reciente al más antiguo.
    func getTodayEntries() async throws -> [LogEntry]

    /// Devuelve todos los registros dentro de un rango de fechas, del más reciente al más antiguo.
    ///
    /// - Parameters:
    ///   - startDate: Inicio del rango (inclusivo).
    ///   - endDate: Fin del rango (exclusivo).
    func getEntries(from startDate: Date, to endDate: Date) async throws -> [LogEntry]
}
