// MARK: - FoodMapperTests.swift
//
// ¿Qué probamos aquí?
// Que FoodMapper convierte correctamente DTOs en entidades Food.
//
// Son los tests más importantes de la capa Data porque el mapper
// es el puente entre la API y la UI. Un bug aquí significa que
// la UI muestra datos incorrectos aunque la red funcione bien.

import Testing
import Foundation
@testable import Fooco

@Suite("FoodMapper")
struct FoodMapperTests {

    // MARK: - Búsqueda → [Food]

    @Test("Mapea el array completo de búsqueda")
    func mapsSearchResponseToFoodArray() {
        let page = FoodMapper.map(DTOMocks.searchResponse)
        #expect(page.foods.count == 1)
    }

    @Test("Mapea fdcId como id de la entidad")
    func mapsFdcIdToId() {
        let food = FoodMapper.map(DTOMocks.avocadoSearchItem)
        #expect(food.id == 171705)
    }

    @Test("Mapea description como name de la entidad")
    func mapsDescriptionToName() {
        let food = FoodMapper.map(DTOMocks.avocadoSearchItem)
        #expect(food.name == "Avocado, raw")
    }

    @Test("Mapea dataType Foundation correctamente")
    func mapsFoundationDataType() {
        let food = FoodMapper.map(DTOMocks.avocadoSearchItem)
        #expect(food.dataType == .foundation)
    }

    @Test("Mapea dataType SR Legacy correctamente")
    func mapsSRLegacyDataType() {
        let food = FoodMapper.map(DTOMocks.itemWithoutNutrients)
        #expect(food.dataType == .srLegacy)
    }

    @Test("Mapea dataType Branded correctamente")
    func mapsBrandedDataType() {
        let food = FoodMapper.map(DTOMocks.brandedItem)
        #expect(food.dataType == .branded)
        #expect(food.brand    == "Whole Foods Market")
    }

    // MARK: - Nutrientes en búsqueda

    @Test("Mapea calorías desde nutriente #1008")
    func mapsCaloriesFromSearch() {
        let food = FoodMapper.map(DTOMocks.avocadoSearchItem)
        #expect(food.nutrients.calories == 160.0)
    }

    @Test("Mapea proteína desde nutriente #1003")
    func mapsProteinFromSearch() {
        let food = FoodMapper.map(DTOMocks.avocadoSearchItem)
        #expect(food.nutrients.protein == 2.0)
    }

    @Test("Mapea grasa desde nutriente #1004")
    func mapsFatFromSearch() {
        let food = FoodMapper.map(DTOMocks.avocadoSearchItem)
        #expect(food.nutrients.fat == 14.66)
    }

    @Test("Mapea carbohidratos desde nutriente #1005")
    func mapsCarbsFromSearch() {
        let food = FoodMapper.map(DTOMocks.avocadoSearchItem)
        #expect(food.nutrients.carbs == 8.53)
    }

    @Test("Mapea fibra como opcional desde nutriente #1079")
    func mapsFiberFromSearch() {
        let food = FoodMapper.map(DTOMocks.avocadoSearchItem)
        #expect(food.nutrients.fiber == 6.7)
    }

    @Test("Sin nutrientes usa 0.0 para los principales")
    func usesZeroForMissingMainNutrients() {
        let food = FoodMapper.map(DTOMocks.itemWithoutNutrients)

        #expect(food.nutrients.calories == 0.0)
        #expect(food.nutrients.protein  == 0.0)
        #expect(food.nutrients.fat      == 0.0)
        #expect(food.nutrients.carbs    == 0.0)
    }

    @Test("Sin nutrientes usa nil para los secundarios")
    func usesNilForMissingSecondaryNutrients() {
        let food = FoodMapper.map(DTOMocks.itemWithoutNutrients)

        #expect(food.nutrients.fiber  == nil)
        #expect(food.nutrients.sugar  == nil)
        #expect(food.nutrients.sodium == nil)
    }

    // MARK: - Detalle → Food

    @Test("Mapea fdcId del detalle como id")
    func mapsDetailFdcIdToId() {
        let food = FoodMapper.map(DTOMocks.avocadoDetail)
        #expect(food.id == 171705)
    }

    @Test("Mapea calorías del detalle desde nutrient.id == 1008")
    func mapsCaloriesFromDetail() {
        let food = FoodMapper.map(DTOMocks.avocadoDetail)
        #expect(food.nutrients.calories == 160.0)
    }

    @Test("Mapea proteína del detalle desde nutrient.id == 1003")
    func mapsProteinFromDetail() {
        let food = FoodMapper.map(DTOMocks.avocadoDetail)
        #expect(food.nutrients.protein == 2.0)
    }

    @Test("Mapea fibra del detalle como opcional")
    func mapsFiberFromDetail() {
        let food = FoodMapper.map(DTOMocks.avocadoDetail)
        #expect(food.nutrients.fiber == 6.7)
    }

    @Test("El resultado de búsqueda y detalle tienen los mismos nutrientes")
    func searchAndDetailProduceSameNutrients() {
        let fromSearch = FoodMapper.map(DTOMocks.avocadoSearchItem)
        let fromDetail = FoodMapper.map(DTOMocks.avocadoDetail)

        #expect(fromSearch.nutrients.calories == fromDetail.nutrients.calories)
        #expect(fromSearch.nutrients.protein  == fromDetail.nutrients.protein)
        #expect(fromSearch.nutrients.fat      == fromDetail.nutrients.fat)
        #expect(fromSearch.nutrients.carbs    == fromDetail.nutrients.carbs)
    }
}
