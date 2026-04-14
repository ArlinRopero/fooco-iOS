// MARK: - SearchViewModel.swift
//
// Maneja el estado de la pantalla de búsqueda, incluyendo scroll infinito.
//
// Flujo de búsqueda:
//   View (escribe query) → ViewModel.search()
//     → QueryTranslatorProtocol ("pollo" → "chicken")
//     → SearchFoodUseCase.execute(query:page:1) → FoodSearchPage
//     → FoodNameTranslatorProtocol (nombres EN → idioma dispositivo)
//   ViewModel (actualiza state + foods) → View (re-renderiza)
//
// Flujo de "cargar más" (scroll infinito):
//   View (sentinel visible) → ViewModel.loadMore()
//     → SearchFoodUseCase.execute(query:page:currentPage+1)
//     → append a foods existentes
//
// Notas de concurrencia:
//   - loadMore() guarda en isLoadingMore para evitar peticiones duplicadas
//   - loadMore() usa la última query traducida (lastTranslatedQuery)
//     para no re-traducir en cada página

import Foundation

// MARK: - SearchViewModel

@Observable
@MainActor
final class SearchViewModel {

    // MARK: - Estado de UI

    var query: String = ""
    var foods: [Food] = []
    var state: SearchState = .idle

    /// true mientras se carga una página adicional (no la primera búsqueda).
    private(set) var isLoadingMore: Bool = false

    /// true si hay más páginas disponibles para esta búsqueda.
    private(set) var canLoadMore: Bool = false

    /// Alimentos que el usuario registra con más frecuencia.
    private(set) var frequentFoods: [Food] = []

    // MARK: - Estado de paginación (privado)

    private var currentPage: Int = 1
    private var totalPages:  Int = 1

    /// Query ya traducida al inglés, usada para páginas adicionales.
    private var lastTranslatedQuery: String = ""

    // MARK: - Dependencias

    private let searchUseCase: any SearchFoodUseCaseProtocol
    let translator: any QueryTranslatorProtocol
    private let frequentFoodsUseCase: (any GetFrequentFoodsUseCaseProtocol)?
    let logFoodUseCase: (any LogFoodUseCaseProtocol)?
    let foodNameTranslator: any FoodNameTranslatorProtocol

    // MARK: - Init

    init(
        searchUseCase: any SearchFoodUseCaseProtocol,
        translator: any QueryTranslatorProtocol = PassthroughQueryTranslator(),
        frequentFoodsUseCase: (any GetFrequentFoodsUseCaseProtocol)? = nil,
        logFoodUseCase: (any LogFoodUseCaseProtocol)? = nil,
        foodNameTranslator: any FoodNameTranslatorProtocol = PassthroughFoodNameTranslator()
    ) {
        self.searchUseCase      = searchUseCase
        self.translator         = translator
        self.frequentFoodsUseCase = frequentFoodsUseCase
        self.logFoodUseCase     = logFoodUseCase
        self.foodNameTranslator = foodNameTranslator
    }

    // MARK: - Búsqueda inicial (página 1)

    /// Ejecuta la búsqueda con la query actual, reseteando la paginación.
    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        state = .loading
        foods = []
        currentPage = 1
        totalPages  = 1
        canLoadMore = false

        let queryForAPI = await translator.translateToEnglish(trimmed)
        lastTranslatedQuery = queryForAPI

        do {
            let page = try await searchUseCase.execute(query: queryForAPI, page: 1)

            if page.foods.isEmpty {
                state = .empty
                return
            }

            foods = await translateNames(page.foods)
            currentPage = page.currentPage
            totalPages  = page.totalPages
            canLoadMore = page.hasMore
            state = .results

        } catch let error as SearchFoodError {
            state = .error(message: error.errorDescription ?? "")
        } catch let error as APIError {
            state = .error(message: error.errorDescription ?? "")
        } catch {
            state = .error(message: error.localizedDescription)
        }
    }

    // MARK: - Cargar más (scroll infinito)

    /// Carga la siguiente página y hace append a los resultados existentes.
    ///
    /// - Precondición: `canLoadMore == true` y `!isLoadingMore`.
    /// - Falla silenciosamente — si la red falla, el usuario puede intentar
    ///   jalando el scroll de nuevo.
    func loadMore() async {
        guard canLoadMore, !isLoadingMore, !lastTranslatedQuery.isEmpty else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        let nextPage = currentPage + 1
        guard let page = try? await searchUseCase.execute(query: lastTranslatedQuery, page: nextPage) else {
            return
        }

        let newFoods = await translateNames(page.foods)
        foods.append(contentsOf: newFoods)
        currentPage = page.currentPage
        totalPages  = page.totalPages
        canLoadMore = page.hasMore
    }

    // MARK: - Clear

    func clear() {
        query               = ""
        foods               = []
        state               = .idle
        currentPage         = 1
        totalPages          = 1
        canLoadMore         = false
        lastTranslatedQuery = ""
    }

    // MARK: - Frecuentes

    func loadFrequentFoods() async {
        guard let useCase = frequentFoodsUseCase else { return }
        frequentFoods = (try? await useCase.execute(limit: 6)) ?? []
    }

    // MARK: - Helper privado

    /// Traduce los nombres EN → idioma del dispositivo y construye el array final.
    private func translateNames(_ rawFoods: [Food]) async -> [Food] {
        let names           = rawFoods.map { $0.name }
        let translatedNames = await foodNameTranslator.translateNames(names)
        return zip(rawFoods, translatedNames).map { food, translatedName in
            Food(id: food.id, name: translatedName, dataType: food.dataType,
                 brand: food.brand, nutrients: food.nutrients)
        }
    }
}

// MARK: - SearchState

enum SearchState: Equatable {
    case idle
    case loading
    case results
    case empty
    case error(message: String)
}
