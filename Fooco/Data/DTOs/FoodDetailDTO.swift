// MARK: - FoodDetailDTO.swift
//
// DTO para el endpoint de detalle:
//   GET /food/{fdcId}?api_key=xxx
//
// Los nutrientes vienen en formato anidado:
// {
//   "fdcId": 173573,
//   "description": "Oil, avocado",
//   "dataType": "SR Legacy",
//   "foodCategory": { "id": 4, "description": "Fats and Oils", "code": "0400" },
//   "foodPortions": [
//     { "id": 92854, "amount": 1, "gramWeight": 14, "modifier": "tbsp", ... }
//   ],
//   "foodAttributes": [
//     { "id": 3329434, "name": "Scientific Name", "value": "Persea americana" }
//   ],
//   "foodNutrients": [
//     {
//       "amount": 884,
//       "nutrient": { "id": 1008, "name": "Energy", "unitName": "kcal", ... }
//     }
//   ]
// }
//
// Nota: algunos items de foodNutrients NO tienen `amount` (son categorías/agrupadores).
// Por eso `amount` es opcional — los ignoramos al mapear.

import Foundation

// MARK: - FoodDetailDTO

struct FoodDetailDTO: Codable, Sendable {
    let fdcId: Int
    let description: String
    let dataType: String?
    let publicationDate: String?
    let foodNutrients: [DetailFoodNutrientDTO]?
    let foodCategory: FoodCategoryDTO?
    let foodPortions: [FoodPortionDTO]?
    let foodAttributes: [FoodAttributeDTO]?
}

// MARK: - DetailFoodNutrientDTO

/// Nutriente en el endpoint de detalle — formato anidado.
///
/// `amount` es nil en items que son solo encabezados de categoría (sin valor real).
/// `nutrient` contiene el ID que usamos para identificar qué nutriente es.
struct DetailFoodNutrientDTO: Codable, Sendable {

    /// Valor del nutriente por 100g. Nil en items sin medición.
    let amount: Double?

    /// Información descriptiva del nutriente — aquí está el ID USDA.
    let nutrient: NutrientInfoDTO?
}

// MARK: - NutrientInfoDTO

struct NutrientInfoDTO: Codable, Sendable {

    /// ID del nutriente en USDA. Ej: 1008 = kcal, 1003 = proteína, 1004 = grasa.
    let id: Int

    let number: String?
    let name: String
    let unitName: String
    let rank: Int?
}

// MARK: - FoodCategoryDTO

/// Categoría del alimento según la clasificación USDA.
/// Ej: "Fats and Oils", "Poultry Products", "Vegetables and Vegetable Products"
struct FoodCategoryDTO: Codable, Sendable {
    let id: Int?
    let description: String?
    let code: String?
}

// MARK: - FoodPortionDTO

/// Porción de referencia del alimento (medida estándar).
///
/// `modifier` es la unidad coloquial: "tsp", "tbsp", "cup", "oz", etc.
/// `gramWeight` es el peso equivalente en gramos.
/// `sequenceNumber` define el orden de presentación.
struct FoodPortionDTO: Codable, Sendable {
    let id: Int?
    let amount: Double?
    let gramWeight: Double?
    let modifier: String?
    let sequenceNumber: Int?
}

// MARK: - FoodAttributeDTO

/// Atributo genérico del alimento — incluye metadatos taxonómicos y ontológicos.
///
/// El campo `name` identifica el tipo de atributo.
/// El campo de interés: `name == "Scientific Name"` → nombre científico del alimento.
struct FoodAttributeDTO: Codable, Sendable {
    let id: Int?
    let name: String?
    let value: String?
}
