// MARK: - FoodEntityTests.swift
//
// ¿Qué probamos aquí?
// La lógica propia de la entidad Food:
//   - DataType.init(rawString:) maneja todos los casos posibles
//   - Nutrients.empty tiene los valores correctos
//   - Food es Hashable e Identifiable correctamente

import Testing
import Foundation
@testable import Fooco

@Suite("Food Entity")
struct FoodEntityTests {

    // MARK: - DataType

    @Test("Foundation se mapea correctamente")
    func foundationDataType() {
        #expect(Food.DataType(rawString: "Foundation") == .foundation)
    }

    @Test("SR Legacy se mapea correctamente")
    func srLegacyDataType() {
        #expect(Food.DataType(rawString: "SR Legacy") == .srLegacy)
    }

    @Test("Branded se mapea correctamente")
    func brandedDataType() {
        #expect(Food.DataType(rawString: "Branded") == .branded)
    }

    @Test("String desconocido cae en .unknown")
    func unknownStringFallsToUnknown() {
        #expect(Food.DataType(rawString: "SomeNewType") == .unknown)
    }

    @Test("nil cae en .unknown sin crash")
    func nilStringFallsToUnknown() {
        #expect(Food.DataType(rawString: nil) == .unknown)
    }

    @Test("String vacío cae en .unknown")
    func emptyStringFallsToUnknown() {
        #expect(Food.DataType(rawString: "") == .unknown)
    }

    // MARK: - Nutrients.empty

    @Test("Nutrients.empty tiene ceros en los principales")
    func emptyNutrientsHaveZeroMainValues() {
        let empty = Food.Nutrients.empty

        #expect(empty.calories == 0.0)
        #expect(empty.protein  == 0.0)
        #expect(empty.fat      == 0.0)
        #expect(empty.carbs    == 0.0)
    }

    @Test("Nutrients.empty tiene nil en los secundarios")
    func emptyNutrientsHaveNilSecondaryValues() {
        let empty = Food.Nutrients.empty

        #expect(empty.fiber  == nil)
        #expect(empty.sugar  == nil)
        #expect(empty.sodium == nil)
    }

    // MARK: - Identifiable

    @Test("id de Food es el fdcId")
    func foodIdIsFdcId() {
        #expect(FoodMocks.avocado.id == 171705)
    }

    // MARK: - Hashable

    @Test("Dos Foods con el mismo id son iguales")
    func foodsWithSameIdAreEqual() {
        let food1 = FoodMocks.avocado
        let food2 = Food(
            id:        171705,
            name:      "Avocado, raw",
            dataType:  .foundation,
            brand:     nil,
            nutrients: FoodMocks.avocadoNutrients
        )
        #expect(food1 == food2)
    }

    @Test("Foods con distinto id son distintos")
    func foodsWithDifferentIdsAreNotEqual() {
        #expect(FoodMocks.avocado != FoodMocks.apple)
    }

    @Test("Food se puede guardar en un Set")
    func foodCanBeStoredInSet() {
        // Si Hashable está bien implementado, no habrá duplicados
        let set: Set<Food> = [FoodMocks.avocado, FoodMocks.avocado, FoodMocks.apple]
        #expect(set.count == 2)
    }
}
