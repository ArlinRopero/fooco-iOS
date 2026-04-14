// MARK: - SearchViewModelFrequentFoodsTests.swift
//
// Tests para la funcionalidad de frequentFoods en SearchViewModel.
//
// ¿Qué probamos aquí?
// Que loadFrequentFoods() llena correctamente la propiedad frequentFoods,
// que falla silenciosamente cuando no hay use case o cuando éste lanza un error,
// y que pasa el límite correcto al use case.
//
// ¿Por qué @MainActor en el suite?
// SearchViewModel es @Observable @MainActor — sus propiedades solo se pueden
// leer en el MainActor. El suite debe estar en el mismo actor para acceder a ellas.

import Testing
import Foundation
@testable import Fooco

@Suite("SearchViewModel — frequentFoods")
@MainActor
struct SearchViewModelFrequentFoodsTests {

    // MARK: - SUT factory

    private func makeSUT(
        frequentFoods: [Food] = FoodMocks.searchResults,
        frequentFoodsError: Error? = nil,
        includeFrequentFoodsUseCase: Bool = true
    ) -> (sut: SearchViewModel, frequentUseCase: MockGetFrequentFoodsUseCase?) {
        let searchUseCase = MockSearchFoodUseCase()

        if includeFrequentFoodsUseCase {
            let frequentUseCase = MockGetFrequentFoodsUseCase()
            frequentUseCase.result = frequentFoods
            frequentUseCase.errorToThrow = frequentFoodsError

            let sut = SearchViewModel(
                searchUseCase: searchUseCase,
                frequentFoodsUseCase: frequentUseCase
            )
            return (sut, frequentUseCase)
        } else {
            let sut = SearchViewModel(searchUseCase: searchUseCase)
            return (sut, nil)
        }
    }

    // MARK: - Estado inicial

    @Test("frequentFoods inicia vacío")
    func frequentFoodsStartsEmpty() {
        // Arrange & Act
        let (sut, _) = makeSUT()

        // Assert — antes de llamar a loadFrequentFoods, la lista está vacía
        #expect(sut.frequentFoods.isEmpty)
    }

    // MARK: - Carga exitosa

    @Test("loadFrequentFoods llena frequentFoods con los resultados del use case")
    func loadFrequentFoodsFillsArray() async {
        // Arrange
        let expected = FoodMocks.searchResults
        let (sut, _) = makeSUT(frequentFoods: expected)

        // Act
        await sut.loadFrequentFoods()

        // Assert
        #expect(sut.frequentFoods == expected)
    }

    @Test("loadFrequentFoods pide limit=6")
    func loadFrequentFoodsRequestsLimit6() async {
        // Arrange
        let (sut, frequentUseCase) = makeSUT()

        // Act
        await sut.loadFrequentFoods()

        // Assert
        #expect(frequentUseCase?.lastLimit == 6)
    }

    @Test("loadFrequentFoods llama al use case exactamente una vez")
    func loadFrequentFoodsCallsUseCaseOnce() async {
        // Arrange
        let (sut, frequentUseCase) = makeSUT()

        // Act
        await sut.loadFrequentFoods()

        // Assert
        #expect(frequentUseCase?.callCount == 1)
    }

    // MARK: - Sin use case (nil)

    @Test("loadFrequentFoods sin use case (nil) deja frequentFoods vacío")
    func loadFrequentFoodsWithoutUseCaseLeavesArrayEmpty() async {
        // Arrange — SearchViewModel sin frequentFoodsUseCase
        let (sut, _) = makeSUT(includeFrequentFoodsUseCase: false)

        // Act
        await sut.loadFrequentFoods()

        // Assert
        #expect(sut.frequentFoods.isEmpty)
    }

    // MARK: - Error del use case

    @Test("loadFrequentFoods con error del use case deja frequentFoods vacío (falla silenciosa)")
    func loadFrequentFoodsWithErrorLeavesArrayEmpty() async {
        // Arrange
        let (sut, _) = makeSUT(frequentFoodsError: APIError.httpError(statusCode: 500))

        // Act — no debe lanzar, debe fallar silenciosamente
        await sut.loadFrequentFoods()

        // Assert
        #expect(sut.frequentFoods.isEmpty)
    }
}
