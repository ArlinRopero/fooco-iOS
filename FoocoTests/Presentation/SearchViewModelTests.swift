// MARK: - SearchViewModelTests.swift

import Testing
import Foundation
@testable import Fooco

@Suite("SearchViewModel")
@MainActor
struct SearchViewModelTests {

    // MARK: - SUT factory

    private func makeSUT(
        result: [Food] = FoodMocks.searchResults,
        error: Error? = nil,
        translations: [String: String] = [:]
    ) -> (sut: SearchViewModel, useCase: MockSearchFoodUseCase, translator: MockQueryTranslator) {
        let useCase = MockSearchFoodUseCase()
        useCase.page = FoodSearchPage(foods: result, currentPage: 1, totalPages: 1)
        useCase.errorToThrow = error

        let translator = MockQueryTranslator()
        translator.translations = translations

        let sut = SearchViewModel(searchUseCase: useCase, translator: translator)
        return (sut, useCase, translator)
    }

    // MARK: - Estado inicial

    @Test("Estado inicial es idle con query vacía")
    func initialStateIsIdle() {
        let (sut, _, _) = makeSUT()

        #expect(sut.state == .idle)
        #expect(sut.query == "")
        #expect(sut.foods.isEmpty)
    }

    // MARK: - Búsqueda exitosa

    @Test("Estado pasa a results cuando hay resultados")
    func stateIsResultsWhenFoodsReturned() async {
        let (sut, _, _) = makeSUT()
        sut.query = "aguacate"

        await sut.search()

        #expect(sut.state == .results)
        #expect(sut.foods.count == FoodMocks.searchResults.count)
    }

    @Test("Estado pasa a empty cuando no hay resultados")
    func stateIsEmptyWhenNoResults() async {
        let (sut, _, _) = makeSUT(result: [])
        sut.query = "xyzzy"

        await sut.search()

        #expect(sut.state == .empty)
        #expect(sut.foods.isEmpty)
    }

    // MARK: - Traducción

    @Test("Traduce la query antes de pasarla al use case")
    func translatesQueryBeforeSearch() async {
        let (sut, useCase, _) = makeSUT(
            translations: ["pollo": "chicken"]
        )
        sut.query = "pollo"

        await sut.search()

        #expect(useCase.lastQuery == "chicken")
    }

    @Test("Llama al traductor con la query sin espacios laterales")
    func passestrimmedQueryToTranslator() async {
        let (sut, _, translator) = makeSUT()
        sut.query = "  arroz  "

        await sut.search()

        #expect(translator.receivedQueries.first == "arroz")
    }

    @Test("Usa la query original si la traducción devuelve lo mismo")
    func usesOriginalWhenTranslationIsPassthrough() async {
        let (sut, useCase, _) = makeSUT()
        sut.query = "chicken"

        await sut.search()

        #expect(useCase.lastQuery == "chicken")
    }

    @Test("Llama al traductor exactamente una vez por búsqueda")
    func callsTranslatorOncePerSearch() async {
        let (sut, _, translator) = makeSUT()
        sut.query = "frijoles"

        await sut.search()

        #expect(translator.callCount == 1)
    }

    @Test("Registra múltiples búsquedas correctamente")
    func tracksMultipleSearches() async {
        let (sut, _, translator) = makeSUT(
            translations: ["pollo": "chicken", "arroz": "rice"]
        )

        sut.query = "pollo"
        await sut.search()

        sut.query = "arroz"
        await sut.search()

        #expect(translator.callCount == 2)
        #expect(translator.receivedQueries == ["pollo", "arroz"])
    }

    // MARK: - Paginación

    @Test("canLoadMore es false en página única")
    func canLoadMoreFalseOnSinglePage() async {
        let (sut, _, _) = makeSUT()
        sut.query = "pollo"

        await sut.search()

        #expect(sut.canLoadMore == false)
    }

    @Test("canLoadMore es true cuando hay más páginas")
    func canLoadMoreTrueWhenMultiplePages() async {
        let (sut, useCase, _) = makeSUT()
        useCase.page = FoodSearchPage(foods: FoodMocks.searchResults, currentPage: 1, totalPages: 3)
        sut.query = "pollo"

        await sut.search()

        #expect(sut.canLoadMore == true)
    }

    @Test("search() usa siempre la página 1")
    func searchAlwaysStartsAtPage1() async {
        let (sut, useCase, _) = makeSUT()
        sut.query = "arroz"

        await sut.search()

        #expect(useCase.lastPage == 1)
    }

    // MARK: - Estados de error

    @Test("Estado es error cuando query es muy corta")
    func stateIsErrorForShortQuery() async {
        let (sut, _, _) = makeSUT(error: SearchFoodError.queryTooShort(minimum: 2))
        sut.query = "a"

        await sut.search()

        if case .error = sut.state { } else {
            Issue.record("Se esperaba .error, se obtuvo \(sut.state)")
        }
    }

    @Test("Estado es error cuando la red falla")
    func stateIsErrorOnNetworkFailure() async {
        let (sut, _, _) = makeSUT(error: APIError.httpError(statusCode: 503))
        sut.query = "aguacate"

        await sut.search()

        if case .error = sut.state { } else {
            Issue.record("Se esperaba .error, se obtuvo \(sut.state)")
        }
        #expect(sut.foods.isEmpty)
    }

    // MARK: - Clear

    @Test("Clear resetea estado, query y resultados")
    func clearResetsEverything() async {
        let (sut, _, _) = makeSUT()
        sut.query = "aguacate"
        await sut.search()

        sut.clear()

        #expect(sut.state == .idle)
        #expect(sut.query == "")
        #expect(sut.foods.isEmpty)
        #expect(!sut.canLoadMore)
    }

    @Test("Clear no llama al use case")
    func clearDoesNotCallUseCase() async {
        let (sut, useCase, _) = makeSUT()
        sut.query = "aguacate"
        await sut.search()
        let countBeforeClear = useCase.callCount

        sut.clear()

        #expect(useCase.callCount == countBeforeClear)
    }
}
