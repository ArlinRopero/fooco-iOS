// MARK: - SearchFoodUseCase.swift
//
// Caso de uso de búsqueda de alimentos con paginación.
//
// Flujo:
//   ViewModel → SearchFoodUseCase → FoodRepositoryProtocol → FoodSearchPage

import Foundation

// MARK: - SearchFoodUseCaseProtocol

protocol SearchFoodUseCaseProtocol: Sendable {

    /// Busca alimentos por texto libre.
    ///
    /// - Parameters:
    ///   - query: Término de búsqueda. Ej: "aguacate", "arroz integral"
    ///   - page:  Página a cargar (1-indexed). Default: 1.
    /// - Returns: `FoodSearchPage` con resultados e info de paginación.
    /// - Throws: `APIError` o `SearchFoodError`.
    func execute(query: String, page: Int) async throws -> FoodSearchPage
}

// MARK: - SearchFoodUseCaseProtocol + Default page

extension SearchFoodUseCaseProtocol {
    /// Sobrecarga sin page — por compatibilidad con código existente.
    func execute(query: String) async throws -> FoodSearchPage {
        try await execute(query: query, page: 1)
    }
}

// MARK: - SearchFoodUseCase

struct SearchFoodUseCase: SearchFoodUseCaseProtocol {

    private let repository: any FoodRepositoryProtocol

    /// Mínimo de caracteres para ejecutar una búsqueda.
    private let minimumQueryLength = 2

    /// 10 resultados por página — suficiente para la carga inicial,
    /// el usuario puede pedir más con scroll infinito.
    private let pageSize = 10

    init(repository: any FoodRepositoryProtocol) {
        self.repository = repository
    }

    func execute(query: String, page: Int = 1) async throws -> FoodSearchPage {
        let trimmed = query.trimmingCharacters(in: .whitespaces)

        guard trimmed.count >= minimumQueryLength else {
            throw SearchFoodError.queryTooShort(minimum: minimumQueryLength)
        }

        return try await repository.searchFoods(query: trimmed, pageSize: pageSize, pageNumber: page)
    }
}

// MARK: - SearchFoodError

enum SearchFoodError: Error, LocalizedError, Equatable {

    case queryTooShort(minimum: Int)

    public var errorDescription: String? {
        switch self {
        case .queryTooShort(let minimum):
            return localized(StringKey.Error.searchQueryTooShort, args: minimum)
        }
    }
}
