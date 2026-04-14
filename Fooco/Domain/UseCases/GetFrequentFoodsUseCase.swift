// MARK: - GetFrequentFoodsUseCase.swift
//
// UseCase para obtener los alimentos más registrados por el usuario.
//
// Útil para la pantalla de inicio de Biblioteca:
// "Estos son tus alimentos de siempre — accede rápido sin buscar."

import Foundation

// MARK: - GetFrequentFoodsUseCaseProtocol

protocol GetFrequentFoodsUseCaseProtocol: Sendable {
    func execute(limit: Int) async throws -> [Food]
}

// MARK: - GetFrequentFoodsUseCase

struct GetFrequentFoodsUseCase: GetFrequentFoodsUseCaseProtocol {

    private let repository: any FoodLogRepositoryProtocol

    init(repository: any FoodLogRepositoryProtocol) {
        self.repository = repository
    }

    func execute(limit: Int = 5) async throws -> [Food] {
        try await repository.getFrequentFoods(limit: limit)
    }
}
