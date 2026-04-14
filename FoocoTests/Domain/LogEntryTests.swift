// MARK: - LogEntryTests.swift
//
// Tests para las computed properties de LogEntry.
//
// ¿Qué probamos aquí?
// Que calculatedCalories, calculatedProtein, calculatedCarbs y calculatedFat
// escalan correctamente los valores por 100g según la cantidad registrada.
//
// Fórmula: valor_nutriente = (nutriente_por_100g * grams) / 100

import Testing
import Foundation
@testable import Fooco

@Suite("LogEntry")
struct LogEntryTests {

    // MARK: - SUT factory

    private func makeEntry(
        food: Food = FoodMocks.avocado,
        grams: Double
    ) -> LogEntry {
        LogEntry(
            id: UUID(),
            food: food,
            grams: grams,
            loggedAt: Date()
        )
    }

    // MARK: - calculatedCalories

    @Test("calculatedCalories: 160 kcal/100g * 200g = 320 kcal")
    func calculatedCaloriesFor200g() {
        // Arrange
        let entry = makeEntry(grams: 200)

        // Act & Assert
        // avocado: 160 kcal / 100g → 200g = 320 kcal
        #expect(entry.calculatedCalories == 320.0)
    }

    @Test("calculatedCalories: 160 kcal/100g * 50g = 80 kcal")
    func calculatedCaloriesFor50g() {
        // Arrange
        let entry = makeEntry(grams: 50)

        // Act & Assert
        #expect(entry.calculatedCalories == 80.0)
    }

    @Test("calculatedCalories con 100g es igual a food.nutrients.calories exactamente")
    func calculatedCaloriesFor100gMatchesNutrients() {
        // Arrange
        let entry = makeEntry(grams: 100)

        // Act & Assert
        #expect(entry.calculatedCalories == FoodMocks.avocadoNutrients.calories)
    }

    // MARK: - calculatedProtein

    @Test("calculatedProtein es proporcional a grams")
    func calculatedProteinIsProportional() {
        // Arrange
        let entry200 = makeEntry(grams: 200)
        let entry100 = makeEntry(grams: 100)

        // Act & Assert
        // avocado: 2.0g proteína / 100g → 200g = 4.0g
        #expect(entry200.calculatedProtein == entry100.calculatedProtein * 2)
    }

    @Test("calculatedProtein: 2.0g/100g * 150g = 3.0g")
    func calculatedProteinFor150g() {
        // Arrange
        let entry = makeEntry(grams: 150)

        // Act & Assert
        #expect(entry.calculatedProtein == 3.0)
    }

    // MARK: - calculatedCarbs

    @Test("calculatedCarbs es proporcional a grams")
    func calculatedCarbsIsProportional() {
        // Arrange
        let entry200 = makeEntry(grams: 200)
        let entry100 = makeEntry(grams: 100)

        // Act & Assert
        #expect(entry200.calculatedCarbs == entry100.calculatedCarbs * 2)
    }

    @Test("calculatedCarbs: 8.53g/100g * 100g = 8.53g")
    func calculatedCarbsFor100g() {
        // Arrange
        let entry = makeEntry(grams: 100)

        // Act & Assert
        #expect(entry.calculatedCarbs == FoodMocks.avocadoNutrients.carbs)
    }

    // MARK: - calculatedFat

    @Test("calculatedFat es proporcional a grams")
    func calculatedFatIsProportional() {
        // Arrange
        let entry50 = makeEntry(grams: 50)
        let entry100 = makeEntry(grams: 100)

        // Act & Assert
        #expect(entry50.calculatedFat == entry100.calculatedFat / 2)
    }

    @Test("calculatedFat: 14.66g/100g * 200g = 29.32g")
    func calculatedFatFor200g() {
        // Arrange
        let entry = makeEntry(grams: 200)

        // Act & Assert
        // avocado: 14.66g grasa / 100g → 200g = 29.32g
        #expect(entry.calculatedFat == 29.32)
    }
}
