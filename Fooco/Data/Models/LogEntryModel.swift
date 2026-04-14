// MARK: - LogEntryModel.swift
//
// Modelo SwiftData para persistir registros de alimentos.
//
// ¿Por qué no usar Food directamente con @Model?
// Food es una entidad de dominio — no puede depender de SwiftData
// (eso rompería la arquitectura limpia). Solución: aplanar sus campos
// en propiedades simples que SwiftData sí puede guardar.
//
// ¿Por qué `final class` y no `struct`?
// SwiftData requiere `@Model` en clases — es un requisito del framework.
// Para el dominio seguimos usando structs (LogEntry, Food).
// Este @Model solo vive en la capa Data.
//
// Flujo:
//   Food + grams → LogEntryMapper.toModel() → LogEntryModel (guardado en SQLite)
//   LogEntryModel → LogEntryMapper.toDomain() → LogEntry (usado en lógica/UI)

import SwiftData
import Foundation

// MARK: - LogEntryModel

@Model
final class LogEntryModel {

    // MARK: - Identificación del registro

    var id: UUID
    var loggedAt: Date
    var grams: Double

    // MARK: - Datos del alimento (aplanados)
    //
    // No podemos guardar Food directamente (no es @Model).
    // Guardamos sus campos individualmente.

    var fdcId: Int
    var foodName: String
    var foodDataType: String
    var foodBrand: String?

    // MARK: - Nutrientes por 100g

    var calories: Double
    var protein: Double
    var fat: Double
    var carbs: Double
    var fiber: Double?
    var sugar: Double?
    var sodium: Double?

    // MARK: - Init

    init(
        id: UUID,
        loggedAt: Date,
        grams: Double,
        fdcId: Int,
        foodName: String,
        foodDataType: String,
        foodBrand: String?,
        calories: Double,
        protein: Double,
        fat: Double,
        carbs: Double,
        fiber: Double?,
        sugar: Double?,
        sodium: Double?
    ) {
        self.id = id
        self.loggedAt = loggedAt
        self.grams = grams
        self.fdcId = fdcId
        self.foodName = foodName
        self.foodDataType = foodDataType
        self.foodBrand = foodBrand
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
    }
}
