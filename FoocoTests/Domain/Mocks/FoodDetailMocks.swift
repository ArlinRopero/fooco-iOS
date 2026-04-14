// MARK: - FoodDetailMocks.swift
//
// Datos de prueba para FoodDetail, FoodPortion y ExtendedNutrients.
// Valores basados en aceite de aguacate (fdcId: 173573) de la API USDA.

import Foundation
@testable import Fooco

enum FoodDetailMocks {

    static let avocadoPortions: [FoodPortion] = [
        FoodPortion(id: 92856, modifier: "tsp",  gramWeight: 4.5,  amount: 1),
        FoodPortion(id: 92854, modifier: "tbsp", gramWeight: 14.0, amount: 1),
        FoodPortion(id: 92855, modifier: "cup",  gramWeight: 218.0, amount: 1),
    ]

    static let avocadoExtended = ExtendedNutrients(
        calcium:           nil,
        iron:              nil,
        magnesium:         nil,
        phosphorus:        nil,
        potassium:         nil,
        zinc:              nil,
        vitaminC:          nil,
        vitaminB6:         nil,
        folate:            nil,
        vitaminB12:        nil,
        vitaminA:          nil,
        saturatedFat:      11.56,
        monounsaturatedFat: 70.55,
        polyunsaturatedFat: 13.49
    )

    static let avocadoDetail = FoodDetail(
        fdcId:          173573,
        category:       "Fats and Oils",
        scientificName: "Persea americana",
        portions:       avocadoPortions,
        extended:       avocadoExtended
    )
}
