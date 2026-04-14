// MARK: - FirestoreFoodLogDTO.swift
//
// Representa el documento Firestore en:
//   users/{uid}/foodLogs/{logId}
//
// ¿Por qué guardar el snapshot completo del alimento?
// Si la API de USDA actualiza los nutrientes de un alimento,
// el historial del usuario NO debe cambiar retroactivamente.
// La decisión de comer 100g de aguacate a las 12:00 de hoy
// tuvo un valor nutricional en ese momento — lo fijamos aquí.
//
// Retención Freemium:
//   deleteAt = loggedAt + retentionDays
//   Firestore TTL elimina automáticamente el documento cuando
//   deleteAt < now. Configurar el TTL en Firebase Console →
//   Firestore → Configuración de TTL → campo: "deleteAt".
//
// Nutrientes calculados (al momento del log):
//   calculatedCalories = calories * grams / 100
//   Se guardan para queries eficientes sin recalcular en el cliente.

import FirebaseFirestore
import Foundation

// MARK: - FirestoreFoodLogDTO

struct FirestoreFoodLogDTO: Codable {

    // MARK: - Identificación

    @DocumentID var documentId: String?

    // MARK: - Registro

    var loggedAt: Timestamp
    var grams: Double

    // MARK: - Snapshot del alimento (fijo en el momento del log)

    var fdcId: Int
    var foodName: String
    var foodDataType: String
    var foodBrand: String?

    // MARK: - Nutrientes por 100g (snapshot)

    var calories: Double
    var protein: Double
    var fat: Double
    var carbs: Double
    var fiber: Double?
    var sugar: Double?
    var sodium: Double?

    // MARK: - Nutrientes calculados para este log (grams/100 * nutriente)
    //
    // Se guardan pre-calculados para que las queries de historial
    // puedan ordenar y filtrar por calorías sin recalcular en cliente.

    var calculatedCalories: Double
    var calculatedProtein: Double
    var calculatedFat: Double
    var calculatedCarbs: Double

    // MARK: - TTL para retención Freemium

    /// Firestore borra automáticamente este documento cuando deleteAt < now.
    /// Configurar en Firebase Console → Firestore → TTL → campo "deleteAt".
    var deleteAt: Timestamp

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case loggedAt, grams
        case fdcId, foodName, foodDataType, foodBrand
        case calories, protein, fat, carbs, fiber, sugar, sodium
        case calculatedCalories, calculatedProtein, calculatedFat, calculatedCarbs
        case deleteAt
    }

    // MARK: - Domain → DTO

    init(from entry: LogEntry, retentionDays: Int) {
        let food = entry.food
        let factor = entry.grams / 100

        self.loggedAt       = Timestamp(date: entry.loggedAt)
        self.grams          = entry.grams

        // Snapshot fijo del alimento
        self.fdcId          = food.id
        self.foodName       = food.name
        self.foodDataType   = food.dataType.rawValue
        self.foodBrand      = food.brand

        // Nutrientes por 100g (snapshot)
        self.calories       = food.nutrients.calories
        self.protein        = food.nutrients.protein
        self.fat            = food.nutrients.fat
        self.carbs          = food.nutrients.carbs
        self.fiber          = food.nutrients.fiber
        self.sugar          = food.nutrients.sugar
        self.sodium         = food.nutrients.sodium

        // Calculados
        self.calculatedCalories = food.nutrients.calories * factor
        self.calculatedProtein  = food.nutrients.protein  * factor
        self.calculatedFat      = food.nutrients.fat      * factor
        self.calculatedCarbs    = food.nutrients.carbs    * factor

        // TTL
        let deleteDate = Calendar.current.date(
            byAdding: .day,
            value: retentionDays,
            to: entry.loggedAt
        ) ?? entry.loggedAt
        self.deleteAt = Timestamp(date: deleteDate)
    }

    // MARK: - DTO → Domain

    func toDomain(id: UUID = UUID()) -> LogEntry {
        let nutrients = Food.Nutrients(
            calories: calories,
            protein:  protein,
            fat:      fat,
            carbs:    carbs,
            fiber:    fiber,
            sugar:    sugar,
            sodium:   sodium
        )

        let food = Food(
            id:       fdcId,
            name:     foodName,
            dataType: Food.DataType(rawValue: foodDataType) ?? .unknown,
            brand:    foodBrand,
            nutrients: nutrients
        )

        return LogEntry(
            id:       id,
            food:     food,
            grams:    grams,
            loggedAt: loggedAt.dateValue()
        )
    }
}
