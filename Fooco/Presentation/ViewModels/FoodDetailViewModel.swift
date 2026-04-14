// MARK: - FoodDetailViewModel.swift
//
// ViewModel de la pantalla de detalle de un alimento.
//
// El Food llega completo desde la búsqueda (con macros traducidos).
// No hay carga inicial — la pantalla se abre instantáneamente.
//
// "Saber más" (opcional):
//   Cuando el usuario toca el botón, se carga FoodDetail desde la API:
//   categoría, porciones, minerales, vitaminas, desglose de grasas.
//   Esto es bajo demanda — la mayoría de usuarios no lo necesita.

import Foundation

// MARK: - FoodDetailViewModel

@Observable
@MainActor
final class FoodDetailViewModel {

    // MARK: - Estado de UI

    /// Alimento recibido desde la lista de búsqueda, con nombre ya traducido.
    var food: Food

    /// Detalle ampliado cargado al tocar "Saber más". Nil hasta que el usuario lo pide.
    private(set) var fullDetail: FoodDetail?

    /// true mientras se carga el detalle ampliado.
    private(set) var isLoadingFullDetail: Bool = false

    /// Mensaje de error si la carga del detalle ampliado falla.
    private(set) var fullDetailError: String?

    /// true durante el breve momento de confirmación tras registrar el alimento.
    private(set) var isLogged: Bool = false

    // MARK: - Dependencias

    private let getFullDetailUseCase: (any GetFoodDetailUseCaseProtocol)?
    private let logFoodUseCase: (any LogFoodUseCaseProtocol)?

    // MARK: - Init

    init(
        food: Food,
        getFullDetailUseCase: (any GetFoodDetailUseCaseProtocol)? = nil,
        logFoodUseCase: (any LogFoodUseCaseProtocol)? = nil
    ) {
        self.food                = food
        self.getFullDetailUseCase = getFullDetailUseCase
        self.logFoodUseCase      = logFoodUseCase
    }

    // MARK: - Acciones

    /// Carga el detalle ampliado desde el endpoint de detalle.
    ///
    /// Llamado al tocar "Saber más". Solo ejecuta si no hay detalle ya cargado.
    func loadFullDetail() async {
        guard let useCase = getFullDetailUseCase, fullDetail == nil else { return }

        isLoadingFullDetail = true
        fullDetailError     = nil

        do {
            fullDetail = try await useCase.execute(fdcId: food.id)
        } catch let error as GetFoodDetailError {
            fullDetailError = error.errorDescription
        } catch let error as APIError {
            fullDetailError = error.errorDescription
        } catch {
            fullDetailError = error.localizedDescription
        }

        isLoadingFullDetail = false
    }

    /// Registra el alimento con la cantidad indicada.
    ///
    /// Muestra confirmación visual durante 2 segundos y luego la oculta.
    func logFood(grams: Double = 100) async {
        guard let useCase = logFoodUseCase else { return }
        do {
            try await useCase.execute(food: food, grams: grams)
            isLogged = true
            try? await Task.sleep(for: .seconds(2))
            isLogged = false
        } catch {
            // Fallo silencioso — el usuario puede reintentar
        }
    }
}
