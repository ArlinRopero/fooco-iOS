// MARK: - Food.swift
//
// ¿Qué es una entidad de dominio?
// Es el modelo central de la app — independiente de cualquier API,
// base de datos o framework. Si mañana cambias de USDA a otra API,
// este archivo no se toca.
//
// ¿Por qué no usar el DTO directamente en la UI?
// Los DTOs tienen problemas para la UI:
//   - "description" en lugar de "name"
//   - Nutrientes como array [SearchFoodNutrientDTO] en lugar de propiedades
//   - Muchos opcionales que la UI tiene que manejar
//   - Acoplamiento: si la API cambia su JSON, la UI se rompe
//
// La entidad resuelve todo eso:
//   DTO.description         → Food.name
//   DTO.foodNutrients[...]  → Food.nutrients.calories, .protein, .fat...
//   Opcionales innecesarios → valores con default (0.0)
//
// Flujo:
//   FoodSearchResponseDTO → (FoodMapper) → [Food]  → ViewModel → View
//   FoodDetailDTO         → (FoodMapper) → Food    → ViewModel → View
//
// Arquitectura: Clean Architecture
//   Domain es el círculo más interno — no depende de nada externo.
//   Solo Foundation (para UUID, etc.) está permitido aquí.

import Foundation

// MARK: - Food

/// Entidad central de la app. Representa un alimento con su información
/// nutricional lista para mostrar en la UI.
///
/// - `Identifiable`: SwiftUI puede usarla directamente en `List` y `ForEach`.
/// - `Hashable`: permite guardarla en Sets (útil para favoritos).
/// - `Sendable`: se puede pasar entre actores sin warnings en Swift 6.
struct Food: Identifiable, Hashable, Sendable {

    // MARK: - Identificación

    /// ID único del alimento. Viene del `fdcId` de USDA.
    /// Es el que se usa para pedir el detalle: GET /food/{id}
    let id: Int

    /// Nombre limpio del alimento.
    /// Viene de `description` en el DTO — renombrado para claridad.
    let name: String

    /// Origen de los datos nutricionales.
    /// Afecta la calidad y completitud de los nutrientes.
    let dataType: DataType

    /// Marca del producto. Solo presente en alimentos "Branded".
    /// Para Foundation y SR Legacy siempre es nil.
    let brand: String?

    // MARK: - Nutrición

    /// Valores nutricionales por 100g del alimento.
    let nutrients: Nutrients
}

// MARK: - Food.DataType

extension Food {

    /// Tipo de base de datos de donde viene el alimento.
    ///
    /// Afecta la confianza en los datos:
    /// - Foundation: datos de referencia de alta calidad (USDA)
    /// - srLegacy: base de datos histórica, también confiable
    /// - branded: datos aportados por marcas, calidad variable
    /// - unknown: cualquier otro tipo no mapeado
    enum DataType: String, Hashable, Sendable {
        case foundation = "Foundation"
        case srLegacy   = "SR Legacy"
        case branded    = "Branded"
        case unknown

        /// Inicializador que acepta el string de la API y cae en .unknown
        /// si no reconoce el valor — nunca falla con un crash.
        init(rawString: String?) {
            self = DataType(rawValue: rawString ?? "") ?? .unknown
        }
    }
}

// MARK: - Food.Nutrients

extension Food {

    /// Valores nutricionales por 100g del alimento.
    ///
    /// ¿Por qué struct anidado y no propiedades planas en Food?
    /// Agrupa datos relacionados, facilita pasar solo los nutrientes
    /// a componentes de UI especializados, y deja Food más legible.
    ///
    /// Los valores son `Double` (no opcional) con default 0.0 para
    /// los nutrientes principales — la UI no necesita manejar nil
    /// para calorías, proteína, grasa y carbohidratos.
    /// Los menos críticos (fibra, azúcar, sodio) son opcionales
    /// porque genuinamente pueden no tener datos en la API.
    struct Nutrients: Hashable, Sendable, Codable {

        // MARK: Principales (siempre presentes)

        /// Energía en kilocalorías. Nutriente #1008 en USDA.
        let calories: Double

        /// Proteína en gramos. Nutriente #1003 en USDA.
        let protein: Double

        /// Grasa total en gramos. Nutriente #1004 en USDA.
        let fat: Double

        /// Carbohidratos totales en gramos. Nutriente #1005 en USDA.
        let carbs: Double

        // MARK: Secundarios (pueden no tener datos)

        /// Fibra dietética en gramos. Nutriente #1079 en USDA.
        let fiber: Double?

        /// Azúcares totales en gramos. Nutriente #2000 en USDA.
        let sugar: Double?

        /// Sodio en miligramos. Nutriente #1093 en USDA.
        let sodium: Double?

        // MARK: - Instancia vacía

        /// Nutrientes sin datos — útil como placeholder mientras carga el detalle.
        static let empty = Nutrients(
            calories: 0, protein: 0, fat: 0, carbs: 0,
            fiber: nil, sugar: nil, sodium: nil
        )

        // MARK: - Hashable / Equatable (explícito, nonisolated)
        //
        // ¿Por qué no dejar que Swift los sintetice automáticamente?
        // En Swift 6, si el tipo es usado en contextos @MainActor, el compilador
        // puede inferir que las implementaciones sintetizadas también son @MainActor.
        // Eso genera el warning: "Main actor-isolated conformance of 'Nutrients'
        // to 'Hashable' cannot be used in nonisolated context".
        //
        // Con `nonisolated` declaramos explícitamente que estas funciones
        // pueden ejecutarse en cualquier contexto de concurrencia — que es
        // lo correcto para un struct puro de valor.

        nonisolated static func == (lhs: Nutrients, rhs: Nutrients) -> Bool {
            lhs.calories == rhs.calories &&
            lhs.protein  == rhs.protein  &&
            lhs.fat      == rhs.fat      &&
            lhs.carbs    == rhs.carbs    &&
            lhs.fiber    == rhs.fiber    &&
            lhs.sugar    == rhs.sugar    &&
            lhs.sodium   == rhs.sodium
        }

        nonisolated func hash(into hasher: inout Hasher) {
            hasher.combine(calories)
            hasher.combine(protein)
            hasher.combine(fat)
            hasher.combine(carbs)
            hasher.combine(fiber)
            hasher.combine(sugar)
            hasher.combine(sodium)
        }
    }
}

// MARK: - Food: Hashable / Equatable (explícito, nonisolated)
//
// Misma razón que en Food.Nutrients — evitar que el compilador genere
// implementaciones @MainActor-isolated de los requisitos de Hashable.

extension Food {

    nonisolated static func == (lhs: Food, rhs: Food) -> Bool {
        lhs.id        == rhs.id        &&
        lhs.name      == rhs.name      &&
        lhs.dataType  == rhs.dataType  &&
        lhs.brand     == rhs.brand     &&
        lhs.nutrients == rhs.nutrients
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(dataType)
        hasher.combine(brand)
        hasher.combine(nutrients)
    }
}
