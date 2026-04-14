// MARK: - SearchFlowIntegrationTests.swift
//
// Tests de integración del flujo de búsqueda.
//
// Qué mockeamos y qué no:
//   ✅ Real: SearchFoodUseCase, FoodMapper, FoodRepository (lógica)
//   ✅ Real: PassthroughQueryTranslator (sin Apple Translation en tests)
//   🔧 Mock: NetworkManager (para no hacer llamadas reales a USDA)
//   🔧 Mock: QueryTranslator (controlamos la "traducción")
//
// Esto verifica:
//   ViewModel → UseCase → Repository → Mapper → ViewModel

import Testing
import Foundation
@testable import Fooco

@Suite("SearchFlow Integration", .serialized)
@MainActor
struct SearchFlowIntegrationTests {

    // MARK: - Helpers

    private func makeStack(
        networkResponse: (any Encodable)? = nil,
        networkError: Error? = nil,
        translations: [String: String] = [:]
    ) -> (viewModel: SearchViewModel, networkMock: MockNetworkManager) {

        let networkMock = MockNetworkManager()
        networkMock.responseData = networkResponse
        networkMock.errorToThrow = networkError

        let repository = FoodRepository(networkManager: networkMock)
        let useCase    = SearchFoodUseCase(repository: repository)

        let translator = MockQueryTranslator()
        translator.translations = translations

        let viewModel = SearchViewModel(
            searchUseCase: useCase,
            translator: translator
        )

        return (viewModel, networkMock)
    }

    // MARK: - Flujo exitoso

    @Test("Flujo completo: query → traducción → búsqueda → resultados mapeados")
    func fullSearchFlowReturnsMapppedFoods() async {
        let (vm, _) = makeStack(
            networkResponse: DTOMocks.searchResponse,
            translations: ["aguacate": "avocado"]
        )
        vm.query = "aguacate"

        await vm.search()

        #expect(vm.state    == .results)
        #expect(vm.foods.count == 1)
        #expect(vm.foods.first?.name == "Avocado, raw")
        #expect(vm.foods.first?.id   == 171705)
    }

    @Test("Los nutrientes se mapean correctamente en el flujo completo")
    func fullFlowMapsNutrientsCorrectly() async {
        let (vm, _) = makeStack(networkResponse: DTOMocks.searchResponse)
        vm.query = "avocado"

        await vm.search()

        let nutrients = vm.foods.first?.nutrients
        #expect(nutrients?.calories == 160.0)
        #expect(nutrients?.protein  == 2.0)
        #expect(nutrients?.fat      == 14.66)
        #expect(nutrients?.fiber    == 6.7)
    }

    @Test("La query traducida llega al NetworkManager")
    func translatedQueryReachesNetworkManager() async {
        let (vm, networkMock) = makeStack(
            networkResponse: DTOMocks.searchResponse,
            translations: ["pollo": "chicken"]
        )
        vm.query = "pollo"

        await vm.search()

        if let router = networkMock.lastRouter as? FoodRouter,
           case let FoodRouter.search(query, _, _) = router {
            #expect(query == "chicken")
        } else {
            Issue.record("NetworkManager no recibió un FoodRouter.search")
        }
    }

    @Test("Flujo completo: respuesta vacía → estado empty")
    func emptyResponseResultsInEmptyState() async {
        let emptyResponse = FoodSearchResponseDTO(
            totalHits: 0, currentPage: 1, totalPages: 0, foods: []
        )
        let (vm, _) = makeStack(networkResponse: emptyResponse)
        vm.query = "xyzzyblerg"

        await vm.search()

        #expect(vm.state     == .empty)
        #expect(vm.foods.isEmpty)
    }

    // MARK: - Flujo de error

    @Test("Error de red llega hasta el ViewModel correctamente")
    func networkErrorReachesViewModel() async {
        let (vm, _) = makeStack(networkError: APIError.httpError(statusCode: 503))
        vm.query = "chicken"

        await vm.search()

        if case .error(let message) = vm.state {
            #expect(!message.isEmpty)
        } else {
            Issue.record("Se esperaba .error, se obtuvo \(vm.state)")
        }
    }

    @Test("Error de datos vacíos llega hasta el ViewModel")
    func noDataErrorReachesViewModel() async {
        let (vm, _) = makeStack(networkError: APIError.noData)
        vm.query = "chicken"

        await vm.search()

        if case .error = vm.state { } else {
            Issue.record("Se esperaba .error, se obtuvo \(vm.state)")
        }
        #expect(vm.foods.isEmpty)
    }

    // MARK: - Validación en el flujo

    @Test("Query muy corta se bloquea antes de llegar al NetworkManager")
    func shortQueryNeverReachesNetwork() async {
        let (vm, networkMock) = makeStack(networkResponse: DTOMocks.searchResponse)
        vm.query = "a"

        await vm.search()

        #expect(networkMock.callCount == 0)
        if case .error = vm.state { } else {
            Issue.record("Se esperaba .error para query corta")
        }
    }

    @Test("Clear después de resultado limpia todo el estado")
    func clearAfterResultsResetsState() async {
        let (vm, _) = makeStack(networkResponse: DTOMocks.searchResponse)
        vm.query = "avocado"
        await vm.search()
        #expect(vm.state == .results)

        vm.clear()

        #expect(vm.state     == .idle)
        #expect(vm.query     == "")
        #expect(vm.foods.isEmpty)
        #expect(!vm.canLoadMore)
    }
}
