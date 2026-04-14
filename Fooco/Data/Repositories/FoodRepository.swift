// MARK: - FoodRepository.swift
//
// Implementación concreta de FoodRepositoryProtocol.
//
// Responsabilidades:
//   1. Llamar al NetworkManager con el Router correcto
//   2. Recibir el DTO crudo de la API
//   3. Pasarlo por FoodMapper para obtener entidades limpias
//   4. Devolver al UseCase solo entidades de Domain

import Foundation

// MARK: - FoodRepository

actor FoodRepository: FoodRepositoryProtocol {

    // MARK: - Dependencias

    private let networkManager: any NetworkManagerProtocol

    // MARK: - Init

    init(networkManager: any NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    // MARK: - FoodRepositoryProtocol

    /// Busca alimentos con paginación.
    ///
    /// Flujo:
    ///   FoodRouter.search → NetworkManager → FoodSearchResponseDTO → FoodMapper → FoodSearchPage
    func searchFoods(query: String, pageSize: Int = 10, pageNumber: Int = 1) async throws -> FoodSearchPage {
        let router = FoodRouter.search(query: query, pageSize: pageSize, pageNumber: pageNumber)
        let dto: FoodSearchResponseDTO = try await networkManager.request(router)
        return FoodMapper.map(dto)
    }

    /// Obtiene el detalle ampliado de un alimento.
    ///
    /// Flujo:
    ///   FoodRouter.detail → NetworkManager → FoodDetailDTO → FoodMapper.mapToFoodDetail → FoodDetail
    func getFoodDetail(fdcId: Int) async throws -> FoodDetail {
        let router = FoodRouter.detail(fdcId: fdcId)
        let dto: FoodDetailDTO = try await networkManager.request(router)
        return FoodMapper.mapToFoodDetail(dto)
    }
}
