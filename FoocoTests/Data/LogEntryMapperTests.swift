// MARK: - LogEntryMapperTests.swift
//
// Tests para LogEntryMapper.
//
// ¿Qué probamos aquí?
// Que la conversión entre la entidad de dominio (Food + grams)
// y el modelo de persistencia (LogEntryModel) es fiel en ambas direcciones.
//
// Un bug aquí significa que los datos guardados no coinciden con
// lo que el usuario registró, o que al recuperarlos se pierden datos.

import Testing
import Foundation
@testable import Fooco

@Suite("LogEntryMapper")
struct LogEntryMapperTests {

    // MARK: - toModel: campos principales

    @Test("toModel preserva fdcId del food")
    func toModelPreservesFdcId() {
        // Arrange & Act
        let model = LogEntryMapper.toModel(food: FoodMocks.avocado, grams: 100)

        // Assert
        #expect(model.fdcId == FoodMocks.avocado.id)
    }

    @Test("toModel preserva el nombre del food")
    func toModelPreservesFoodName() {
        // Arrange & Act
        let model = LogEntryMapper.toModel(food: FoodMocks.avocado, grams: 100)

        // Assert
        #expect(model.foodName == FoodMocks.avocado.name)
    }

    @Test("toModel preserva los grams")
    func toModelPreservesGrams() {
        // Arrange & Act
        let model = LogEntryMapper.toModel(food: FoodMocks.avocado, grams: 175.5)

        // Assert
        #expect(model.grams == 175.5)
    }

    @Test("toModel preserva las calorías")
    func toModelPreservesCalories() {
        // Arrange & Act
        let model = LogEntryMapper.toModel(food: FoodMocks.avocado, grams: 100)

        // Assert
        #expect(model.calories == FoodMocks.avocadoNutrients.calories)
    }

    @Test("toModel preserva la proteína")
    func toModelPreservesProtein() {
        // Arrange & Act
        let model = LogEntryMapper.toModel(food: FoodMocks.avocado, grams: 100)

        // Assert
        #expect(model.protein == FoodMocks.avocadoNutrients.protein)
    }

    @Test("toModel preserva la grasa")
    func toModelPreservesFat() {
        // Arrange & Act
        let model = LogEntryMapper.toModel(food: FoodMocks.avocado, grams: 100)

        // Assert
        #expect(model.fat == FoodMocks.avocadoNutrients.fat)
    }

    @Test("toModel preserva los carbohidratos")
    func toModelPreservesCarbs() {
        // Arrange & Act
        let model = LogEntryMapper.toModel(food: FoodMocks.avocado, grams: 100)

        // Assert
        #expect(model.carbs == FoodMocks.avocadoNutrients.carbs)
    }

    // MARK: - toModel: brand

    @Test("toModel preserva brand nil cuando el food no tiene marca")
    func toModelPreservesNilBrand() {
        // Arrange & Act — avocado no tiene brand
        let model = LogEntryMapper.toModel(food: FoodMocks.avocado, grams: 100)

        // Assert
        #expect(model.foodBrand == nil)
    }

    @Test("toModel preserva brand con valor cuando el food tiene marca")
    func toModelPreservesBrandValue() {
        // Arrange & Act — almondButter tiene brand "Whole Foods Market"
        let model = LogEntryMapper.toModel(food: FoodMocks.almondButter, grams: 30)

        // Assert
        #expect(model.foodBrand == "Whole Foods Market")
    }

    // MARK: - toModel: nutrientes opcionales

    @Test("toModel preserva fiber cuando existe en el food")
    func toModelPreservesFiberWhenPresent() {
        // Arrange & Act — avocado tiene fiber = 6.7
        let model = LogEntryMapper.toModel(food: FoodMocks.avocado, grams: 100)

        // Assert
        #expect(model.fiber == FoodMocks.avocadoNutrients.fiber)
    }

    @Test("toModel preserva sugar cuando existe en el food")
    func toModelPreservesSugarWhenPresent() {
        // Arrange & Act — avocado tiene sugar = 0.66
        let model = LogEntryMapper.toModel(food: FoodMocks.avocado, grams: 100)

        // Assert
        #expect(model.sugar == FoodMocks.avocadoNutrients.sugar)
    }

    @Test("toModel preserva sodium cuando existe en el food")
    func toModelPreservesSodiumWhenPresent() {
        // Arrange & Act — avocado tiene sodium = 7.0
        let model = LogEntryMapper.toModel(food: FoodMocks.avocado, grams: 100)

        // Assert
        #expect(model.sodium == FoodMocks.avocadoNutrients.sodium)
    }

    @Test("toModel preserva fiber como nil cuando el food no lo tiene")
    func toModelPreservesNilFiber() {
        // Arrange & Act — apple tiene fiber = nil
        let model = LogEntryMapper.toModel(food: FoodMocks.apple, grams: 100)

        // Assert
        #expect(model.fiber == nil)
    }

    @Test("toModel preserva sugar como nil cuando el food no lo tiene")
    func toModelPreservesNilSugar() {
        // Arrange & Act — apple tiene sugar = nil
        let model = LogEntryMapper.toModel(food: FoodMocks.apple, grams: 100)

        // Assert
        #expect(model.sugar == nil)
    }

    @Test("toModel preserva sodium como nil cuando el food no lo tiene")
    func toModelPreservesNilSodium() {
        // Arrange & Act — apple tiene sodium = nil
        let model = LogEntryMapper.toModel(food: FoodMocks.apple, grams: 100)

        // Assert
        #expect(model.sodium == nil)
    }

    // MARK: - toDomain: roundtrip

    @Test("toDomain(toModel) recupera el mismo food y grams — roundtrip completo")
    func roundtripPreservesAllData() {
        // Arrange
        let originalFood = FoodMocks.avocado
        let originalGrams = 250.0
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

        // Act
        let model = LogEntryMapper.toModel(food: originalFood, grams: originalGrams, loggedAt: fixedDate)
        let entry = LogEntryMapper.toDomain(model)

        // Assert — los datos del alimento se recuperan íntegros
        #expect(entry.food.id == originalFood.id)
        #expect(entry.food.name == originalFood.name)
        #expect(entry.food.brand == originalFood.brand)
        #expect(entry.food.nutrients.calories == originalFood.nutrients.calories)
        #expect(entry.food.nutrients.protein == originalFood.nutrients.protein)
        #expect(entry.food.nutrients.fat == originalFood.nutrients.fat)
        #expect(entry.food.nutrients.carbs == originalFood.nutrients.carbs)
        #expect(entry.food.nutrients.fiber == originalFood.nutrients.fiber)
        #expect(entry.food.nutrients.sugar == originalFood.nutrients.sugar)
        #expect(entry.food.nutrients.sodium == originalFood.nutrients.sodium)
        #expect(entry.grams == originalGrams)
    }

    @Test("toDomain preserva loggedAt")
    func toDomainPreservesLoggedAt() {
        // Arrange
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let model = LogEntryMapper.toModel(food: FoodMocks.avocado, grams: 100, loggedAt: fixedDate)

        // Act
        let entry = LogEntryMapper.toDomain(model)

        // Assert
        #expect(entry.loggedAt == fixedDate)
    }

    // MARK: - toDomain: dataType

    @Test("toDomain convierte dataType Foundation correctamente")
    func toDomainConvertsFoundationDataType() {
        // Arrange — avocado es .foundation
        let model = LogEntryMapper.toModel(food: FoodMocks.avocado, grams: 100)

        // Act
        let entry = LogEntryMapper.toDomain(model)

        // Assert
        #expect(entry.food.dataType == .foundation)
    }

    @Test("toDomain convierte dataType SR Legacy correctamente")
    func toDomainConvertsSRLegacyDataType() {
        // Arrange — apple es .srLegacy
        let model = LogEntryMapper.toModel(food: FoodMocks.apple, grams: 100)

        // Act
        let entry = LogEntryMapper.toDomain(model)

        // Assert
        #expect(entry.food.dataType == .srLegacy)
    }

    @Test("toDomain convierte dataType Branded correctamente")
    func toDomainConvertsBrandedDataType() {
        // Arrange — almondButter es .branded
        let model = LogEntryMapper.toModel(food: FoodMocks.almondButter, grams: 30)

        // Act
        let entry = LogEntryMapper.toDomain(model)

        // Assert
        #expect(entry.food.dataType == .branded)
    }
}
