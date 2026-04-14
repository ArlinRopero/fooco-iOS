// MARK: - AnalyticsEvent.swift
//
// Catálogo de eventos de Analytics de Fooco.
//
// ¿Por qué enum y no strings sueltos?
// El compilador garantiza que no haya typos en los nombres de eventos.
// Un string mal escrito ("saber_mmas_viewed") compila pero nunca aparece
// en la consola de Firebase — muy difícil de debuggear.
//
// Modelo Freemium — eventos clave a medir:
//   • ¿Cuántos usuarios ven "Saber más"? (engagement con el detalle)
//   • ¿Qué condición de salud tiene el usuario que registra un alimento?
//     (segmentación para contenido Premium)
//   • ¿Con qué frecuencia crean recetas? (feature stickiness)
//   • ¿Cuándo consultan el historial? (hábito de uso diario)

import Foundation

// MARK: - AnalyticsEvent

enum AnalyticsEvent {

    // MARK: - Pantalla de detalle

    /// El usuario abrió la sección "Saber más" de un alimento.
    case saberMasViewed(foodId: Int, foodName: String)

    // MARK: - Registro de alimentos

    /// El usuario guardó un alimento en su log diario.
    case foodLogged(
        foodId: Int,
        foodName: String,
        grams: Double,
        calories: Double,
        healthConditions: [String]  // condiciones activas del perfil
    )

    // MARK: - Recetas

    /// El usuario creó o guardó una receta.
    case recipeCreated(recipeId: String, healthTags: [String], isPublic: Bool)

    // MARK: - Historial

    /// El usuario abrió la vista de historial semanal.
    case weeklyHistoryViewed

    // MARK: - Perfil

    /// El usuario completó su perfil (tiene peso, altura, año y sexo).
    case profileCompleted(hasConditions: Bool, activityLevel: String)

    // MARK: - Freemium

    /// El usuario intentó acceder a una función Premium estando en Free.
    case premiumGateReached(featureName: String)

    /// El usuario inició o completó una suscripción Premium.
    case premiumSubscribed(tier: String)

    // MARK: - Nombre del evento (Firebase Analytics convention: snake_case, ≤ 40 chars)

    var name: String {
        switch self {
        case .saberMasViewed:      return "saber_mas_viewed"
        case .foodLogged:          return "food_logged"
        case .recipeCreated:       return "recipe_created"
        case .weeklyHistoryViewed: return "weekly_history_viewed"
        case .profileCompleted:    return "profile_completed"
        case .premiumGateReached:  return "premium_gate_reached"
        case .premiumSubscribed:   return "premium_subscribed"
        }
    }

    // MARK: - Parámetros del evento (Firebase Analytics max: 25 params, ≤ 100 chars cada uno)

    var parameters: [String: Any] {
        switch self {

        case let .saberMasViewed(foodId, foodName):
            return [
                "food_id":   foodId,
                "food_name": foodName
            ]

        case let .foodLogged(foodId, foodName, grams, calories, conditions):
            return [
                "food_id":           foodId,
                "food_name":         foodName,
                "grams":             grams,
                "calories":          calories,
                "health_conditions": conditions.joined(separator: ",")
            ]

        case let .recipeCreated(recipeId, healthTags, isPublic):
            return [
                "recipe_id":   recipeId,
                "health_tags": healthTags.joined(separator: ","),
                "is_public":   isPublic ? 1 : 0
            ]

        case .weeklyHistoryViewed:
            return [:]

        case let .profileCompleted(hasConditions, activityLevel):
            return [
                "has_conditions": hasConditions ? 1 : 0,
                "activity_level": activityLevel
            ]

        case let .premiumGateReached(featureName):
            return ["feature_name": featureName]

        case let .premiumSubscribed(tier):
            return ["tier": tier]
        }
    }
}
