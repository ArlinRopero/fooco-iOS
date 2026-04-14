// MARK: - DTODecodingTests.swift
//
// ¿Qué probamos aquí?
// Que nuestros DTOs decodifican correctamente el JSON real de la API.
//
// ¿Por qué es importante?
// Si la API cambia un nombre de campo ("fdcId" → "fdc_id"),
// estos tests lo atraparán inmediatamente antes de que la app
// llegue a producción con datos rotos.
//
// Patrón: usamos los JSON strings de DTOMocks para simular
// exactamente lo que llegaría de la red.

import Testing
import Foundation
@testable import Fooco

@Suite("DTO Decoding")
struct DTODecodingTests {

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private func decode<T: Decodable>(_ type: T.Type, from json: String) throws -> T {
        let data = Data(json.utf8)
        return try decoder.decode(type, from: data)
    }

    // MARK: - FoodSearchResponseDTO

    @Test("Decodifica totalHits, currentPage y totalPages")
    func decodesSearchPagination() throws {
        let dto = try decode(FoodSearchResponseDTO.self, from: DTOMocks.searchResponseJSON)

        #expect(dto.totalHits   == 42)
        #expect(dto.currentPage == 1)
        #expect(dto.totalPages  == 3)
    }

    @Test("Decodifica el array de foods")
    func decodesSearchFoodsArray() throws {
        let dto = try decode(FoodSearchResponseDTO.self, from: DTOMocks.searchResponseJSON)

        #expect(dto.foods.count == 1)
    }

    @Test("Decodifica fdcId y description del alimento")
    func decodesSearchItemIdentity() throws {
        let dto = try decode(FoodSearchResponseDTO.self, from: DTOMocks.searchResponseJSON)
        let food = try #require(dto.foods.first)

        #expect(food.fdcId       == 171705)
        #expect(food.description == "Avocado, raw")
        #expect(food.dataType    == "Foundation")
    }

    @Test("Decodifica los nutrientes en búsqueda")
    func decodesSearchNutrients() throws {
        let dto = try decode(FoodSearchResponseDTO.self, from: DTOMocks.searchResponseJSON)
        let nutrients = try #require(dto.foods.first?.foodNutrients)

        #expect(nutrients.count == 7)

        // La API devuelve nutrientId (Int largo), nutrientNumber (String corto), value (Double)
        let calories = nutrients.first(where: { $0.nutrientId == 1008 })
        #expect(calories?.value          == 160.0)
        #expect(calories?.nutrientNumber == "208")
        #expect(calories?.unitName       == "KCAL")
    }

    @Test("Decodifica alimento sin nutrientes sin crash")
    func decodesItemWithoutNutrients() throws {
        let dto = try decode(FoodSearchResponseDTO.self, from: DTOMocks.searchItemWithoutNutrientsJSON)
        let food = try #require(dto.foods.first)

        // foodNutrients es nil cuando no viene en el JSON — no debe crashear
        #expect(food.foodNutrients == nil)
        #expect(food.fdcId == 999999)
    }

    // MARK: - FoodDetailDTO

    @Test("Decodifica fdcId y description del detalle")
    func decodesDetailIdentity() throws {
        let dto = try decode(FoodDetailDTO.self, from: DTOMocks.detailResponseJSON)

        #expect(dto.fdcId       == 171705)
        #expect(dto.description == "Avocado, raw")
        #expect(dto.dataType    == "Foundation")
    }

    @Test("Decodifica los nutrientes anidados del detalle")
    func decodesDetailNutrients() throws {
        let dto = try decode(FoodDetailDTO.self, from: DTOMocks.detailResponseJSON)
        let nutrients = try #require(dto.foodNutrients)

        #expect(nutrients.count == 7)
    }

    @Test("Decodifica el objeto nutriente anidado correctamente")
    func decodesNestedNutrientObject() throws {
        let dto = try decode(FoodDetailDTO.self, from: DTOMocks.detailResponseJSON)
        let nutrients = try #require(dto.foodNutrients)

        let calories = nutrients.first(where: { $0.nutrient?.id == 1008 })
        #expect(calories?.amount         == 160.0)
        #expect(calories?.nutrient?.name == "Energy")
        #expect(calories?.nutrient?.unitName == "kcal")
    }

    @Test("Decodifica proteína del detalle con valor correcto")
    func decodesProteinValue() throws {
        let dto = try decode(FoodDetailDTO.self, from: DTOMocks.detailResponseJSON)
        let nutrients = try #require(dto.foodNutrients)

        let protein = nutrients.first(where: { $0.nutrient?.id == 1003 })
        #expect(protein?.amount == 2.0)
    }
}
