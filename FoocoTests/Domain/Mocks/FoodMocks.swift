// MARK: - FoodMocks.swift
//
// Entidades Food prefabricadas para tests de dominio, ViewModels y Views.
//
// ¿Por qué tener mocks de entidades además de mocks de DTOs?
// Los tests de capas superiores (ViewModel, View) no deben depender
// del mapper ni de los DTOs — reciben Food directamente.
// Estos mocks les dan datos limpios sin pasar por toda la cadena.
//
// Regla: los mocks deben ser representativos pero simples.
// Usamos el aguacate como food principal porque tiene valores
// nutricionales conocidos y fáciles de verificar en los tests.

import Foundation
@testable import Fooco

// MARK: - FoodMocks

enum FoodMocks {

    // MARK: - Nutrients

    /// Nutrientes completos del aguacate (valores reales USDA).
    static let avocadoNutrients = Food.Nutrients(
        calories: 160.0,
        protein:  2.0,
        fat:      14.66,
        carbs:    8.53,
        fiber:    6.7,
        sugar:    0.66,
        sodium:   7.0
    )

    /// Nutrientes solo con los principales — sin opcionales.
    static let minimalNutrients = Food.Nutrients(
        calories: 52.0,
        protein:  0.26,
        fat:      0.17,
        carbs:    13.81,
        fiber:    nil,
        sugar:    nil,
        sodium:   nil
    )

    // MARK: - Foods

    /// Aguacate crudo — Foundation, sin marca, con todos los nutrientes.
    static let avocado = Food(
        id:        171705,
        name:      "Avocado, raw",
        dataType:  .foundation,
        brand:     nil,
        nutrients: avocadoNutrients
    )

    /// Manzana — SR Legacy, sin marca, con nutrientes mínimos.
    static let apple = Food(
        id:        9003,
        name:      "Apples, raw, with skin",
        dataType:  .srLegacy,
        brand:     nil,
        nutrients: minimalNutrients
    )

    /// Mantequilla de almendras — Branded, con marca.
    static let almondButter = Food(
        id:        888888,
        name:      "Organic Almond Butter",
        dataType:  .branded,
        brand:     "Whole Foods Market",
        nutrients: .empty
    )

    /// Alimento con tipo desconocido — para probar el caso .unknown.
    static let unknownTypeFood = Food(
        id:        777777,
        name:      "Mystery Food",
        dataType:  .unknown,
        brand:     nil,
        nutrients: .empty
    )

    // MARK: - Listas

    /// Lista de búsqueda con variedad de tipos.
    static let searchResults: [Food] = [avocado, apple, almondButter]
}
