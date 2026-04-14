// MARK: - LogEntryMapper.swift
//
// Convierte entre LogEntryModel (SwiftData) y LogEntry (dominio).
//
// ¿Por qué un mapper separado y no métodos en el modelo?
// El modelo (@Model class) no debe saber sobre las entidades de dominio.
// El mapper vive en Data — conoce ambos lados y hace la conversión.
// Las entidades de dominio quedan limpias de lógica de persistencia.

import Foundation

// MARK: - LogEntryMapper

enum LogEntryMapper {

    // MARK: - Domain → Model

    /// Convierte un Food + grams en un LogEntryModel listo para persistir.
    static func toModel(
        food: Food,
        grams: Double,
        loggedAt: Date = Date()
    ) -> LogEntryModel {
        LogEntryModel(
            id: UUID(),
            loggedAt: loggedAt,
            grams: grams,
            fdcId: food.id,
            foodName: food.name,
            foodDataType: food.dataType.rawValue,
            foodBrand: food.brand,
            calories: food.nutrients.calories,
            protein: food.nutrients.protein,
            fat: food.nutrients.fat,
            carbs: food.nutrients.carbs,
            fiber: food.nutrients.fiber,
            sugar: food.nutrients.sugar,
            sodium: food.nutrients.sodium
        )
    }

    // MARK: - Model → Domain

    /// Convierte un LogEntryModel guardado en una entidad de dominio LogEntry.
    static func toDomain(_ model: LogEntryModel) -> LogEntry {
        let food = Food(
            id: model.fdcId,
            name: model.foodName,
            dataType: Food.DataType(rawString: model.foodDataType),
            brand: model.foodBrand,
            nutrients: Food.Nutrients(
                calories: model.calories,
                protein: model.protein,
                fat: model.fat,
                carbs: model.carbs,
                fiber: model.fiber,
                sugar: model.sugar,
                sodium: model.sodium
            )
        )
        return LogEntry(
            id: model.id,
            food: food,
            grams: model.grams,
            loggedAt: model.loggedAt
        )
    }
}
