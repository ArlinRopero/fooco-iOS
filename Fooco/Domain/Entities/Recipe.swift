// MARK: - Recipe.swift
//
// Entidad de dominio para recetas personalizadas latinas.
//
// Diseño Freemium:
//   Free    → puede crear recetas, solo visibles para él
//   Premium → puede publicar recetas (isPublic = true) para que
//             otros usuarios las descubran en el explorador

import Foundation

// MARK: - RecipeIngredient

struct RecipeIngredient: Equatable, Sendable, Codable {
    var name: String
    var grams: Double
    var nutrients: Food.Nutrients

    /// Calorías aportadas por este ingrediente según los gramos indicados.
    var contributedCalories: Double { nutrients.calories * grams / 100 }
}

// MARK: - Recipe

struct Recipe: Identifiable, Equatable, Sendable {

    // MARK: - Identificación

    var id: String              // Firestore document ID
    var authorId: String        // Firebase Auth UID

    // MARK: - Contenido

    var name: String
    var description: String?
    var origin: String?         // "colombiana", "mexicana", "peruana", …

    // MARK: - Ingredientes

    var ingredients: [RecipeIngredient]

    // MARK: - Nutrientes totales (calculados al guardar)

    var totalNutrients: Food.Nutrients

    // MARK: - Clasificación y visibilidad

    var healthTags: Set<HealthCondition>    // Apta para estas condiciones
    var isPublic: Bool

    // MARK: - Metadata

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Init

    init(
        id: String = UUID().uuidString,
        authorId: String,
        name: String,
        description: String? = nil,
        origin: String? = nil,
        ingredients: [RecipeIngredient] = [],
        healthTags: Set<HealthCondition> = [],
        isPublic: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id             = id
        self.authorId       = authorId
        self.name           = name
        self.description    = description
        self.origin         = origin
        self.ingredients    = ingredients
        self.healthTags     = healthTags
        self.isPublic       = isPublic
        self.createdAt      = createdAt
        self.updatedAt      = updatedAt
        self.totalNutrients = Self.calculateNutrients(from: ingredients)
    }

    // MARK: - Computed

    var totalCalories: Double { totalNutrients.calories }

    /// Recalcula los nutrientes totales sumando todos los ingredientes.
    mutating func recalculateNutrients() {
        totalNutrients = Self.calculateNutrients(from: ingredients)
    }

    private static func calculateNutrients(from ingredients: [RecipeIngredient]) -> Food.Nutrients {
        ingredients.reduce(Food.Nutrients(calories: 0, protein: 0, fat: 0, carbs: 0, fiber: 0, sugar: 0, sodium: 0)) { acc, ingredient in
            let factor = ingredient.grams / 100
            return Food.Nutrients(
                calories: acc.calories + ingredient.nutrients.calories * factor,
                protein:  acc.protein  + ingredient.nutrients.protein  * factor,
                fat:      acc.fat      + ingredient.nutrients.fat       * factor,
                carbs:    acc.carbs    + ingredient.nutrients.carbs     * factor,
                fiber:    (acc.fiber   ?? 0) + (ingredient.nutrients.fiber  ?? 0) * factor,
                sugar:    (acc.sugar   ?? 0) + (ingredient.nutrients.sugar  ?? 0) * factor,
                sodium:   (acc.sodium  ?? 0) + (ingredient.nutrients.sodium ?? 0) * factor
            )
        }
    }
}
