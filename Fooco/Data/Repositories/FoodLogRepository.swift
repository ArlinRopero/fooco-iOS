// MARK: - FoodLogRepository.swift
//
// Implementación del repositorio de registros usando SwiftData.
//
// ¿Por qué @ModelActor y no @MainActor?
// @ModelActor crea un actor dedicado con su propio ModelContext.
// Esto permite leer/escribir en background sin bloquear el hilo principal.
// iOS 17+ recomienda este patrón para SwiftData en capas de datos.
//
// ¿Cómo recibe el ModelContainer?
// El macro @ModelActor genera automáticamente:
//   init(modelContainer: ModelContainer)
// Se llama desde FoocoApp al arrancar la app.
//
// ¿Por qué calcular frecuencia en código y no con una query?
// SwiftData (iOS 17) no soporta GROUP BY ni COUNT con predicados complejos.
// Con pocos registros (diario personal), traer todos y agrupar en memoria
// es perfectamente eficiente y más simple de mantener.

import SwiftData
import Foundation

// MARK: - FoodLogRepository

@ModelActor
actor FoodLogRepository: FoodLogRepositoryProtocol {

    // MARK: - FoodLogRepositoryProtocol

    func logFood(_ food: Food, grams: Double) async throws {
        let model = LogEntryMapper.toModel(food: food, grams: grams)
        modelContext.insert(model)
        try modelContext.save()
    }

    func getFrequentFoods(limit: Int) async throws -> [Food] {
        let descriptor = FetchDescriptor<LogEntryModel>()
        let entries = try modelContext.fetch(descriptor)

        // Agrupar por fdcId y contar cuántas veces aparece cada alimento.
        // Guardamos también la instancia del Food para devolver el más reciente.
        var frequency: [Int: (food: Food, count: Int)] = [:]
        for model in entries {
            let entry = LogEntryMapper.toDomain(model)
            let food = entry.food
            if let existing = frequency[food.id] {
                frequency[food.id] = (food, existing.count + 1)
            } else {
                frequency[food.id] = (food, 1)
            }
        }

        return frequency.values
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .map { $0.food }
    }

    func getTodayEntries() async throws -> [LogEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        return try await getEntries(from: startOfDay, to: endOfDay)
    }

    func getEntries(from startDate: Date, to endDate: Date) async throws -> [LogEntry] {
        let predicate = #Predicate<LogEntryModel> { entry in
            entry.loggedAt >= startDate && entry.loggedAt < endDate
        }
        var descriptor = FetchDescriptor<LogEntryModel>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.loggedAt, order: .reverse)]

        return try modelContext.fetch(descriptor).map(LogEntryMapper.toDomain)
    }
}
