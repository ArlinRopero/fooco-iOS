// MARK: - LogEntry.swift
//
// Entidad de dominio que representa un registro de alimento en el diario.
//
// ¿Qué es un LogEntry?
// Es el "evento" de que el usuario comió X gramos de un alimento en un momento dado.
// No es el alimento en sí (eso es Food) — es el acto de haberlo consumido.
//
// ¿Por qué guardar `grams` y no solo el fdcId?
// Los nutrientes de USDA son por 100g. Para calcular lo que el usuario comió
// necesitamos: nutriente_real = nutriente_100g * (grams / 100)
// Sin los gramos, no podemos hacer ese cálculo.
//
// ¿Por qué `loggedAt: Date` y no solo la fecha?
// Guardamos el timestamp completo para poder agrupar por día, semana, mes
// y mostrar el historial cronológico.

import Foundation

// MARK: - LogEntry

/// Registro de consumo de un alimento.
///
/// Representa que el usuario comió `grams` gramos de `food` en `loggedAt`.
struct LogEntry: Identifiable, Sendable {

    /// ID único del registro. Generado localmente al crear.
    let id: UUID

    /// Alimento consumido — datos completos del momento en que se registró.
    let food: Food

    /// Gramos consumidos. Siempre > 0.
    let grams: Double

    /// Cuándo se registró. Timestamp completo.
    let loggedAt: Date

    // MARK: - Nutrición calculada

    /// Calorías reales consumidas, ajustadas por `grams`.
    var calculatedCalories: Double {
        food.nutrients.calories * (grams / 100)
    }

    /// Proteína real en gramos, ajustada por `grams`.
    var calculatedProtein: Double {
        food.nutrients.protein * (grams / 100)
    }

    /// Carbohidratos reales en gramos, ajustados por `grams`.
    var calculatedCarbs: Double {
        food.nutrients.carbs * (grams / 100)
    }

    /// Grasa real en gramos, ajustada por `grams`.
    var calculatedFat: Double {
        food.nutrients.fat * (grams / 100)
    }
}
