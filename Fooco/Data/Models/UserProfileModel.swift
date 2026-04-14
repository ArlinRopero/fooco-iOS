// MARK: - UserProfileModel.swift
//
// Modelo SwiftData para persistir el perfil del usuario.
//
// Misma razón que LogEntryModel: UserProfile es una entidad de dominio
// (struct puro), no puede llevar @Model. Aplanamos sus campos aquí.
//
// Set<HealthCondition> no es persistible directamente en SwiftData —
// lo serializamos como una cadena CSV (e.g. "anemia,diabetes2").
// El Mapper se encarga de la conversión.
//
// ¿Por qué una sola instancia?
// El perfil del usuario es único. El repositorio garantiza que solo
// haya un UserProfileModel en el store (fetch → update o insert).

import SwiftData
import Foundation

// MARK: - UserProfileModel

@Model
final class UserProfileModel {

    // MARK: - Identificación

    var id: UUID

    // MARK: - Datos personales

    var name: String?
    var biologicalSex: String       // BiologicalSex.rawValue
    var birthYear: Int?
    var weightKg: Double?
    var heightCm: Double?

    // MARK: - Actividad y objetivos

    var activityLevel: String       // ActivityLevel.rawValue
    var dailyCalorieGoal: Int?

    // MARK: - Condiciones de salud (serializado como CSV)
    //
    // Ejemplo: "anemia,diabetes2,pregnancy"
    // SwiftData no soporta Set<Enum> directamente.

    var healthConditionsCSV: String

    // MARK: - Init

    init(
        id: UUID,
        name: String?,
        biologicalSex: String,
        birthYear: Int?,
        weightKg: Double?,
        heightCm: Double?,
        activityLevel: String,
        dailyCalorieGoal: Int?,
        healthConditionsCSV: String
    ) {
        self.id = id
        self.name = name
        self.biologicalSex = biologicalSex
        self.birthYear = birthYear
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.activityLevel = activityLevel
        self.dailyCalorieGoal = dailyCalorieGoal
        self.healthConditionsCSV = healthConditionsCSV
    }
}
