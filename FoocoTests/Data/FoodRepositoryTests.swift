// MARK: - FoodRepositoryTests.swift
//
// Tests de FoodRepository.
//
// ¿Qué testeamos aquí?
// 1. Que searchFoods construye el router correcto y mapea los resultados
// 2. Que getFoodDetail construye el router correcto y mapea el resultado
// 3. Que los errores del NetworkManager se propagan correctamente
//
// Estrategia: inyectamos MockNetworkManager en lugar del real.
// FoodRepository no toca la red — MockNetworkManager devuelve DTOs fijos.
//
// ¿Por qué no usar MockURLProtocol aquí?
// MockURLProtocol es para testear NetworkManager (la capa de red).
// Aquí testeamos FoodRepository (la capa de repositorio) — un nivel arriba.
// Cada capa tiene su propia estrategia de mock.

import Testing
import Foundation
@testable import Fooco

@Suite("FoodRepository")
struct FoodRepositoryTests {

    // MARK: - SUT factory

    /// Crea el repositorio inyectando el mock.
    private func makeSUT(
        response: (any Encodable)? = nil,
        error: Error? = nil
    ) -> (sut: FoodRepository, mock: MockNetworkManager) {
        let mock = MockNetworkManager()
        mock.responseData = response
        mock.errorToThrow = error
        let sut = FoodRepository(networkManager: mock)
        return (sut, mock)
    }

    // MARK: - searchFoods — éxito

    @Test("searchFoods devuelve alimentos mapeados")
    func searchFoodsReturnsMappedFoods() async throws {
        let (sut, _) = makeSUT(response: DTOMocks.searchResponse)

        let foods: FoodSearchPage = try await sut.searchFoods(query: "avocado", pageSize: 20)

        #expect(foods.foods.count == 1)
        await #expect(foods.foods.first?.name == "Avocado, raw")
        await #expect(foods.foods.first?.id   == 171705)
    }

    @Test("searchFoods mapea los nutrientes del resultado")
    func searchFoodsMapsNutrients() async throws {
        let (sut, _) = makeSUT(response: DTOMocks.searchResponse)

        let food: Food? = try await sut.searchFoods(query: "avocado", pageSize: 20).foods.first ?? nil

        let nutrients = try #require(food?.nutrients)
        #expect(nutrients.calories == 160.0)
        #expect(nutrients.protein  == 2.0)
        #expect(nutrients.fat      == 14.66)
    }

    @Test("searchFoods pasa los parámetros correctos al router")
    func searchFoodsBuildsCorrectRouter() async throws {
        let (sut, mock) = makeSUT(response: DTOMocks.searchResponse)

        _ = try await sut.searchFoods(query: "banana", pageSize: 10)

        // Verificamos que el repositorio construyó un FoodRouter.search
        // con exactamente los parámetros que recibió
        guard let router = mock.lastRouter as? FoodRouter,
              case let FoodRouter.search(query, pageSize) = router else {
            Issue.record("Se esperaba FoodRouter.search, se recibió otro router")
            return
        }

        #expect(query    == "banana")
        #expect(pageSize == 10)
    }

    // MARK: - getFoodDetail — éxito

    @Test("getFoodDetail devuelve el alimento mapeado")
    func getFoodDetailReturnsMappedFood() async throws {
        let (sut, _) = makeSUT(response: DTOMocks.avocadoDetail)

        let food: FoodDetail = try await sut.getFoodDetail(fdcId: 171705)

        #expect(food.fdcId   == 171705)
        #expect(food.scientificName == "Avocado, raw")
    }

    @Test("getFoodDetail mapea los nutrientes del detalle")
    func getFoodDetailMapsNutrients() async throws {
        let (sut, _) = makeSUT(response: DTOMocks.avocadoDetail)

        let food: FoodDetail = try await sut.getFoodDetail(fdcId: 171705)

        #expect(food.extended.calories == 160.0)
        #expect(food.extended.fiber    == 6.7)
        #expect(food.extended.sodium   == 7.0)
    }

    @Test("getFoodDetail pasa el fdcId correcto al router")
    func getFoodDetailBuildsCorrectRouter() async throws {
        let (sut, mock) = makeSUT(response: DTOMocks.avocadoDetail)

        _ = try await sut.getFoodDetail(fdcId: 171705)

        guard let router = mock.lastRouter as? FoodRouter,
              case let FoodRouter.detail(fdcId) = router else {
            Issue.record("Se esperaba FoodRouter.detail, se recibió otro router")
            return
        }

        #expect(fdcId == 171705)
    }

    // MARK: - Propagación de errores

    @Test("searchFoods propaga errores de red")
    func searchFoodsPropagatesNetworkError() async throws {
        let (sut, _) = makeSUT(error: APIError.httpError(statusCode: 503))

        await #expect(throws: APIError.httpError(statusCode: 503)) {
            _ = try await sut.searchFoods(query: "anything", pageSize: 20)
        }
    }

    @Test("getFoodDetail propaga errores de red")
    func getFoodDetailPropagatesNetworkError() async throws {
        let (sut, _) = makeSUT(error: APIError.httpError(statusCode: 404))

        await #expect(throws: APIError.httpError(statusCode: 404)) {
            _ = try await sut.getFoodDetail(fdcId: 0)
        }
    }

    @Test("searchFoods propaga error de datos vacíos")
    func searchFoodsPropagatesNoDataError() async throws {
        let (sut, _) = makeSUT(error: APIError.noData)

        await #expect(throws: APIError.noData) {
            _ = try await sut.searchFoods(query: "anything", pageSize: 20)
        }
    }
}
