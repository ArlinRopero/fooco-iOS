// MARK: - MockFoodRepository.swift
//
// Mock de FoodRepositoryProtocol para tests de UseCases.
//
// Patrón Spy + Stub:
//   Spy  → registra qué se llamó y con qué parámetros
//   Stub → devuelve respuestas o errores configurables

import Foundation
@testable import Fooco

final class MockFoodRepository: FoodRepositoryProtocol, @unchecked Sendable {

    // MARK: - Configuración (Stub)

    /// Alimentos que devolverá `searchFoods`. Wrapeados en FoodSearchPage página 1/1.
    var searchResult: [Food] = FoodMocks.searchResults

    /// Override completo de la página devuelta. Nil → usa searchResult.
    var searchPageOverride: FoodSearchPage?

    /// Error que lanzará en cualquier operación (si está configurado).
    var errorToThrow: Error?

    // MARK: - Registro (Spy)

    private(set) var searchCallCount = 0
    private(set) var lastSearchQuery: String?
    private(set) var lastSearchPageSize: Int?
    private(set) var lastSearchPageNumber: Int?

    private(set) var detailCallCount = 0
    private(set) var lastDetailFdcId: Int?

    // MARK: - FoodRepositoryProtocol

    func searchFoods(query: String, pageSize: Int, pageNumber: Int) async throws -> FoodSearchPage {
        searchCallCount += 1
        lastSearchQuery      = query
        lastSearchPageSize   = pageSize
        lastSearchPageNumber = pageNumber

        if let error = errorToThrow { throw error }

        if let override = searchPageOverride { return override }
        return FoodSearchPage(foods: searchResult, currentPage: 1, totalPages: 1)
    }

    func getFoodDetail(fdcId: Int) async throws -> FoodDetail {
        detailCallCount += 1
        lastDetailFdcId = fdcId

        if let error = errorToThrow { throw error }
        return FoodDetailMocks.avocadoDetail
    }
}
