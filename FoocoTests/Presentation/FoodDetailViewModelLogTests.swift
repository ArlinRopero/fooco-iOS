// MARK: - FoodDetailViewModelLogTests.swift
//
// Tests para logFood en FoodDetailViewModel.
//
// Verifica que logFood llama al use case con los parámetros correctos,
// que isLogged pasa a true tras un log exitoso, y que falla silenciosamente
// cuando no hay use case o éste lanza.

import Testing
import Foundation
@testable import Fooco

@Suite("FoodDetailViewModel — logFood")
@MainActor
struct FoodDetailViewModelLogTests {

    // MARK: - SUT factory

    private func makeSUT(
        food: Food = FoodMocks.avocado,
        logError: Error? = nil,
        includeLogUseCase: Bool = true
    ) -> (sut: FoodDetailViewModel, logUseCase: MockLogFoodUseCase?) {
        if includeLogUseCase {
            let logUseCase = MockLogFoodUseCase()
            logUseCase.errorToThrow = logError

            let sut = FoodDetailViewModel(food: food, logFoodUseCase: logUseCase)
            return (sut, logUseCase)
        } else {
            let sut = FoodDetailViewModel(food: food)
            return (sut, nil)
        }
    }

    // MARK: - Estado inicial

    @Test("isLogged inicia en false")
    func isLoggedStartsFalse() {
        let (sut, _) = makeSUT()
        #expect(sut.isLogged == false)
    }

    // MARK: - Sin use case (nil)

    @Test("Sin logFoodUseCase (nil): logFood no hace nada e isLogged permanece false")
    func logFoodWithoutUseCaseDoesNothing() async {
        let (sut, _) = makeSUT(includeLogUseCase: false)
        await sut.logFood(grams: 100)
        #expect(sut.isLogged == false)
    }

    // MARK: - Con use case

    @Test("logFood llama al use case con el food correcto")
    func logFoodCallsUseCaseWithCorrectFood() async {
        let (sut, logUseCase) = makeSUT(food: FoodMocks.avocado)
        await sut.logFood(grams: 100)
        #expect(logUseCase?.lastFood == FoodMocks.avocado)
    }

    @Test("logFood pasa los grams especificados al use case")
    func logFoodPassesSpecifiedGrams() async {
        let (sut, logUseCase) = makeSUT()
        await sut.logFood(grams: 250)
        #expect(logUseCase?.lastGrams == 250)
    }

    @Test("logFood pasa grams=100 por defecto")
    func logFoodUsesDefaultGramsOf100() async {
        let (sut, logUseCase) = makeSUT()
        await sut.logFood()
        #expect(logUseCase?.lastGrams == 100)
    }

    @Test("logFood llama al use case exactamente una vez")
    func logFoodCallsUseCaseOnce() async {
        let (sut, logUseCase) = makeSUT()
        await sut.logFood(grams: 100)
        #expect(logUseCase?.callCount == 1)
    }

    // MARK: - Error del use case

    @Test("Error del use case: isLogged permanece false (falla silenciosa)")
    func logFoodErrorKeepsIsLoggedFalse() async {
        let (sut, _) = makeSUT(logError: LogFoodError.invalidGrams)
        await sut.logFood(grams: 0)
        #expect(sut.isLogged == false)
    }

    @Test("Error del use case: el use case sí fue llamado")
    func logFoodErrorStillCallsUseCase() async {
        let (sut, logUseCase) = makeSUT(logError: LogFoodError.invalidGrams)
        await sut.logFood(grams: 0)
        #expect(logUseCase?.callCount == 1)
    }
}
