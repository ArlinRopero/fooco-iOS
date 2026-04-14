// MARK: - GetFoodDetailUseCase.swift
//
// Caso de uso para obtener el detalle ampliado de un alimento.
//
// ¿Cuándo se usa?
// Cuando el usuario toca "Saber más" en la pantalla de detalle.
// Los datos básicos (macros) ya vienen de la búsqueda.
// Este use case carga lo extra: categoría, porciones, minerales, vitaminas, grasas.
//
// Lógica de negocio aplicada:
//   1. Validar que el ID sea positivo (IDs de USDA siempre > 0)
//   2. Delegar al repositorio
//
// YAGNI: la validación es todo lo que necesitamos ahora.

import Foundation

// MARK: - GetFoodDetailUseCaseProtocol

/// Contrato del caso de uso de detalle ampliado.
protocol GetFoodDetailUseCaseProtocol: Sendable {

    /// Obtiene el detalle ampliado de un alimento.
    ///
    /// - Parameter fdcId: ID único del alimento en la base de datos USDA.
    /// - Returns: `FoodDetail` con categoría, porciones y nutrientes extendidos.
    /// - Throws: `GetFoodDetailError` si el ID es inválido.
    ///           `APIError` si el alimento no existe o la red falla.
    func execute(fdcId: Int) async throws -> FoodDetail
}

// MARK: - GetFoodDetailUseCase

struct GetFoodDetailUseCase: GetFoodDetailUseCaseProtocol {

    private let repository: any FoodRepositoryProtocol

    init(repository: any FoodRepositoryProtocol) {
        self.repository = repository
    }

    func execute(fdcId: Int) async throws -> FoodDetail {
        guard fdcId > 0 else {
            throw GetFoodDetailError.invalidID
        }
        return try await repository.getFoodDetail(fdcId: fdcId)
    }
}

// MARK: - GetFoodDetailError

enum GetFoodDetailError: Error, LocalizedError, Equatable {

    case invalidID

    public var errorDescription: String? {
        switch self {
        case .invalidID:
            return localized(StringKey.Error.foodDetailInvalidID)
        }
    }
}
