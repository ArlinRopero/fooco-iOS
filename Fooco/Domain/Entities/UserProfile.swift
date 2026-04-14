// MARK: - UserProfile.swift
//
// Entidad de dominio que representa el perfil del usuario.
//
// ¿Por qué struct y no class?
// UserProfile es un valor — no tiene identidad ni referencia compartida.
// Immutable por defecto: cualquier cambio produce una copia nueva.
//
// ¿Por qué HealthCondition y ActivityLevel están aquí y no en un archivo aparte?
// Son tipos exclusivamente usados por UserProfile — agruparlos evita
// fragmentar el modelo de dominio en archivos insignificantes.

import Foundation

// MARK: - ActivityLevel

/// Nivel de actividad física del usuario.
/// Se usa para estimar el TDEE (Total Daily Energy Expenditure)
/// mediante el factor de actividad de Harris-Benedict revisado.
enum ActivityLevel: String, CaseIterable, Codable, Sendable {
    case sedentary          // Trabajo de escritorio, sin ejercicio
    case lightlyActive      // Ejercicio 1-3 días/semana
    case moderatelyActive   // Ejercicio 3-5 días/semana
    case veryActive         // Ejercicio intenso 6-7 días/semana
    case extraActive        // Trabajo físico + ejercicio diario intenso

    /// Factor multiplicador sobre la tasa metabólica basal (BMR).
    var factor: Double {
        switch self {
        case .sedentary:        return 1.2
        case .lightlyActive:    return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive:       return 1.725
        case .extraActive:      return 1.9
        }
    }
}

// MARK: - BiologicalSex

/// Sexo biológico del usuario.
/// Se usa para el cálculo de BMR (fórmula Mifflin-St Jeor).
enum BiologicalSex: String, CaseIterable, Codable, Sendable {
    case male
    case female
    case unspecified
}

// MARK: - HealthCondition

/// Condición de salud declarada por el usuario.
/// Permite ajustar los Valores Diarios de Referencia (VDR) de nutrientes clave.
///
/// Ejemplo: anemia eleva el VDR de hierro a 27 mg/día.
enum HealthCondition: String, CaseIterable, Codable, Sendable {
    case anemia
    case diabetes2
    case pregnancy
    case hypertension
    case osteoporosis
    case hypothyroidism
}

// MARK: - UserProfile

/// Perfil del usuario con datos personales, nivel de actividad y condiciones de salud.
///
/// Todos los campos son opcionales para respetar la política de "personalización
/// progresiva": la app funciona desde el día 1 sin perfil, y mejora su precisión
/// a medida que el usuario añade información.
struct UserProfile: Equatable, Sendable {

    // MARK: - Identificación

    var id: UUID

    // MARK: - Datos personales

    var name: String?
    var biologicalSex: BiologicalSex
    var birthYear: Int?
    var weightKg: Double?
    var heightCm: Double?

    // MARK: - Actividad y objetivos

    var activityLevel: ActivityLevel
    var dailyCalorieGoal: Int?

    // MARK: - Condiciones de salud

    var healthConditions: Set<HealthCondition>

    // MARK: - Init

    init(
        id: UUID = UUID(),
        name: String? = nil,
        biologicalSex: BiologicalSex = .unspecified,
        birthYear: Int? = nil,
        weightKg: Double? = nil,
        heightCm: Double? = nil,
        activityLevel: ActivityLevel = .sedentary,
        dailyCalorieGoal: Int? = nil,
        healthConditions: Set<HealthCondition> = []
    ) {
        self.id = id
        self.name = name
        self.biologicalSex = biologicalSex
        self.birthYear = birthYear
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.activityLevel = activityLevel
        self.dailyCalorieGoal = dailyCalorieGoal
        self.healthConditions = healthConditions
    }

    // MARK: - Computed

    /// Calorías diarias estimadas.
    /// Si el usuario definió un objetivo manual, lo retorna directamente.
    /// Si no, calcula el TDEE con Mifflin-St Jeor × factor de actividad.
    /// Retorna nil si faltan datos para el cálculo automático.
    var estimatedDailyCalories: Int? {
        if let goal = dailyCalorieGoal { return goal }
        return calculatedTDEE
    }

    /// TDEE calculado automáticamente con Mifflin-St Jeor.
    /// Requiere: peso, altura, año de nacimiento y sexo biológico (no `.unspecified`).
    var calculatedTDEE: Int? {
        guard
            let weight = weightKg,
            let height = heightCm,
            let year = birthYear,
            biologicalSex != .unspecified
        else { return nil }

        let age = Double(Calendar.current.component(.year, from: Date()) - year)
        guard age > 0 else { return nil }

        let bmr: Double
        switch biologicalSex {
        case .male:
            bmr = 10 * weight + 6.25 * height - 5 * age + 5
        case .female:
            bmr = 10 * weight + 6.25 * height - 5 * age - 161
        case .unspecified:
            return nil
        }

        return Int(bmr * activityLevel.factor)
    }

    /// Indica si el perfil tiene suficientes datos para cálculos nutricionales personalizados.
    var isComplete: Bool {
        weightKg != nil && heightCm != nil && birthYear != nil && biologicalSex != .unspecified
    }
}
