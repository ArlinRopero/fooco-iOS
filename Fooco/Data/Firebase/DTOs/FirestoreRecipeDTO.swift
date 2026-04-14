// MARK: - FirestoreRecipeDTO.swift
//
// Representa el documento Firestore en:
//   users/{uid}/recipes/{recipeId}
//
// Los ingredientes se guardan como array de maps con los campos
// name, grams y el snapshot de nutrientes — mismo patrón que FoodLog.

import FirebaseFirestore
import Foundation

// MARK: - FirestoreIngredientDTO

struct FirestoreIngredientDTO: Codable {
    var name: String
    var grams: Double
    var calories: Double
    var protein: Double
    var fat: Double
    var carbs: Double
    var fiber: Double?
    var sugar: Double?
    var sodium: Double?

    init(ingredient: RecipeIngredient) {
        self.name     = ingredient.name
        self.grams    = ingredient.grams
        self.calories = ingredient.nutrients.calories
        self.protein  = ingredient.nutrients.protein
        self.fat      = ingredient.nutrients.fat
        self.carbs    = ingredient.nutrients.carbs
        self.fiber    = ingredient.nutrients.fiber
        self.sugar    = ingredient.nutrients.sugar
        self.sodium   = ingredient.nutrients.sodium
    }

    func toDomain() -> RecipeIngredient {
        RecipeIngredient(
            name: name,
            grams: grams,
            nutrients: Food.Nutrients(
                calories: calories, protein: protein,
                fat: fat, carbs: carbs,
                fiber: fiber, sugar: sugar, sodium: sodium
            )
        )
    }
}

// MARK: - FirestoreRecipeDTO

struct FirestoreRecipeDTO: Codable {

    @DocumentID var documentId: String?

    var name: String
    var description: String?
    var origin: String?
    var isPublic: Bool
    var healthTags: [String]            // HealthCondition rawValues
    var ingredients: [FirestoreIngredientDTO]

    // Nutrientes totales pre-calculados
    var totalCalories: Double
    var totalProtein: Double
    var totalFat: Double
    var totalCarbs: Double
    var totalFiber: Double?
    var totalSodium: Double?

    var createdAt: Timestamp
    var updatedAt: Timestamp

    enum CodingKeys: String, CodingKey {
        case name, description, origin, isPublic, healthTags, ingredients
        case totalCalories, totalProtein, totalFat, totalCarbs, totalFiber, totalSodium
        case createdAt, updatedAt
    }

    // MARK: - Domain → DTO

    init(recipe: Recipe) {
        self.name           = recipe.name
        self.description    = recipe.description
        self.origin         = recipe.origin
        self.isPublic       = recipe.isPublic
        self.healthTags     = recipe.healthTags.map(\.rawValue).sorted()
        self.ingredients    = recipe.ingredients.map { FirestoreIngredientDTO(ingredient: $0) }
        self.totalCalories  = recipe.totalNutrients.calories
        self.totalProtein   = recipe.totalNutrients.protein
        self.totalFat       = recipe.totalNutrients.fat
        self.totalCarbs     = recipe.totalNutrients.carbs
        self.totalFiber     = recipe.totalNutrients.fiber
        self.totalSodium    = recipe.totalNutrients.sodium
        self.createdAt      = Timestamp(date: recipe.createdAt)
        self.updatedAt      = Timestamp(date: recipe.updatedAt)
    }

    // MARK: - DTO → Domain

    func toDomain(authorId: String) -> Recipe {
        Recipe(
            id:          documentId ?? UUID().uuidString,
            authorId:    authorId,
            name:        name,
            description: description,
            origin:      origin,
            ingredients: ingredients.map { $0.toDomain() },
            healthTags:  Set(healthTags.compactMap(HealthCondition.init(rawValue:))),
            isPublic:    isPublic,
            createdAt:   createdAt.dateValue(),
            updatedAt:   updatedAt.dateValue()
        )
    }
}
