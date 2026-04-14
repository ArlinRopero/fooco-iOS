// MARK: - UserProfileMapper.swift
//
// Convierte entre UserProfile (dominio) y UserProfileModel (SwiftData).
//
// Responsabilidad: traducción de tipos.
// No toca la base de datos — solo transforma valores.

import Foundation

// MARK: - UserProfileMapper

enum UserProfileMapper {

    // MARK: - Domain → Model

    /// Crea un nuevo UserProfileModel a partir de un UserProfile de dominio.
    static func toModel(_ profile: UserProfile) -> UserProfileModel {
        UserProfileModel(
            id: profile.id,
            name: profile.name,
            biologicalSex: profile.biologicalSex.rawValue,
            birthYear: profile.birthYear,
            weightKg: profile.weightKg,
            heightCm: profile.heightCm,
            activityLevel: profile.activityLevel.rawValue,
            dailyCalorieGoal: profile.dailyCalorieGoal,
            healthConditionsCSV: encodeConditions(profile.healthConditions)
        )
    }

    /// Actualiza un UserProfileModel existente con los valores de un UserProfile.
    ///
    /// Mutamos el modelo en lugar de borrarlo y recrearlo para que SwiftData
    /// no genere un cambio de identidad innecesario.
    static func update(_ model: UserProfileModel, from profile: UserProfile) {
        model.name = profile.name
        model.biologicalSex = profile.biologicalSex.rawValue
        model.birthYear = profile.birthYear
        model.weightKg = profile.weightKg
        model.heightCm = profile.heightCm
        model.activityLevel = profile.activityLevel.rawValue
        model.dailyCalorieGoal = profile.dailyCalorieGoal
        model.healthConditionsCSV = encodeConditions(profile.healthConditions)
    }

    // MARK: - Model → Domain

    /// Construye un UserProfile de dominio a partir de un UserProfileModel.
    static func toDomain(_ model: UserProfileModel) -> UserProfile {
        UserProfile(
            id: model.id,
            name: model.name,
            biologicalSex: BiologicalSex(rawValue: model.biologicalSex) ?? .unspecified,
            birthYear: model.birthYear,
            weightKg: model.weightKg,
            heightCm: model.heightCm,
            activityLevel: ActivityLevel(rawValue: model.activityLevel) ?? .sedentary,
            dailyCalorieGoal: model.dailyCalorieGoal,
            healthConditions: decodeConditions(model.healthConditionsCSV)
        )
    }

    // MARK: - Helpers CSV

    private static func encodeConditions(_ conditions: Set<HealthCondition>) -> String {
        conditions.map(\.rawValue).sorted().joined(separator: ",")
    }

    private static func decodeConditions(_ csv: String) -> Set<HealthCondition> {
        guard !csv.isEmpty else { return [] }
        let values = csv.split(separator: ",").map(String.init)
        return Set(values.compactMap(HealthCondition.init(rawValue:)))
    }
}
