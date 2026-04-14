// MARK: - ProfileViewModel.swift
//
// ViewModel de la pantalla de perfil del usuario.
//
// Responsabilidades:
//   • Cargar el perfil guardado al aparecer la pantalla.
//   • Mantener el estado editable de los campos del formulario.
//   • Guardar el perfil cuando el usuario confirma.
//   • Gestionar la búsqueda y selección de condiciones de salud.
//
// ¿Por qué campos individuales en lugar de un UserProfile como @State?
// UserProfile es una struct de dominio con tipos opacos (Set, enum).
// Los campos individuales son más fáciles de bindear a los controles SwiftUI
// (TextField, Picker, Stepper) sin conversiones en la Vista.
// El ViewModel ensambla el UserProfile en save().

import Foundation
import Observation

// MARK: - ProfileViewModel

@Observable
@MainActor
final class ProfileViewModel {

    // MARK: - Estado de pantalla

    private(set) var isLoading = false
    private(set) var isSaving  = false
    var saveSuccess = false
    var errorMessage: String?

    // MARK: - Campos editables del formulario

    var name: String = ""
    var biologicalSex: BiologicalSex = .unspecified
    var birthYear: String = ""          // String para TextField con teclado numérico
    var weightKg: String = ""           // String para TextField con teclado decimal
    var heightCm: String = ""           // String para TextField con teclado decimal
    var activityLevel: ActivityLevel = .sedentary
    var dailyCalorieGoal: String = ""   // Vacío = cálculo automático
    var selectedConditions: Set<HealthCondition> = []

    // MARK: - Búsqueda de condiciones de salud

    var conditionSearchText: String = ""

    var filteredConditions: [HealthCondition] {
        let all = HealthCondition.allCases
        guard !conditionSearchText.isEmpty else { return all }
        return all.filter { condition in
            condition.displayName.localizedCaseInsensitiveContains(conditionSearchText)
        }
    }

    // MARK: - Calculado: TDEE automático

    /// Calorías estimadas con los valores actuales del formulario.
    /// Muestra nil si faltan datos.
    var estimatedCalories: Int? {
        buildProfile().calculatedTDEE
    }

    // MARK: - Dependencias

    private let getProfileUseCase: any GetUserProfileUseCaseProtocol
    private let saveProfileUseCase: any SaveUserProfileUseCaseProtocol

    // MARK: - Estado interno

    private var loadedProfileID: UUID?

    // MARK: - Init

    init(
        getProfileUseCase: any GetUserProfileUseCaseProtocol,
        saveProfileUseCase: any SaveUserProfileUseCaseProtocol
    ) {
        self.getProfileUseCase  = getProfileUseCase
        self.saveProfileUseCase = saveProfileUseCase
    }

    // MARK: - Carga

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            if let profile = try await getProfileUseCase.execute() {
                populate(from: profile)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Guardado

    func save() async {
        isSaving = true
        errorMessage = nil
        saveSuccess = false

        do {
            let profile = buildProfile()
            try await saveProfileUseCase.execute(profile)
            loadedProfileID = profile.id
            saveSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }

    // MARK: - Gestión de condiciones

    func toggleCondition(_ condition: HealthCondition) {
        if selectedConditions.contains(condition) {
            selectedConditions.remove(condition)
        } else {
            selectedConditions.insert(condition)
        }
    }

    // MARK: - Helpers privados

    /// Rellena los campos del formulario con los valores de un UserProfile cargado.
    private func populate(from profile: UserProfile) {
        loadedProfileID    = profile.id
        name               = profile.name ?? ""
        biologicalSex      = profile.biologicalSex
        birthYear          = profile.birthYear.map(String.init) ?? ""
        weightKg           = profile.weightKg.map { formatDecimal($0) } ?? ""
        heightCm           = profile.heightCm.map { formatDecimal($0) } ?? ""
        activityLevel      = profile.activityLevel
        dailyCalorieGoal   = profile.dailyCalorieGoal.map(String.init) ?? ""
        selectedConditions = profile.healthConditions
    }

    /// Construye un UserProfile de dominio con los valores actuales del formulario.
    private func buildProfile() -> UserProfile {
        UserProfile(
            id: loadedProfileID ?? UUID(),
            name: name.isEmpty ? nil : name,
            biologicalSex: biologicalSex,
            birthYear: Int(birthYear),
            weightKg: Double(weightKg.replacingOccurrences(of: ",", with: ".")),
            heightCm: Double(heightCm.replacingOccurrences(of: ",", with: ".")),
            activityLevel: activityLevel,
            dailyCalorieGoal: Int(dailyCalorieGoal),
            healthConditions: selectedConditions
        )
    }

    /// Formatea un Double eliminando el ".0" cuando es un número entero.
    private func formatDecimal(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(value)
    }
}

// MARK: - HealthCondition + displayName

extension HealthCondition {
    var displayName: String {
        switch self {
        case .anemia:         return localized("profile.condition.anemia")
        case .diabetes2:      return localized("profile.condition.diabetes2")
        case .pregnancy:      return localized("profile.condition.pregnancy")
        case .hypertension:   return localized("profile.condition.hypertension")
        case .osteoporosis:   return localized("profile.condition.osteoporosis")
        case .hypothyroidism: return localized("profile.condition.hypothyroidism")
        }
    }
}

// MARK: - ActivityLevel + displayName

extension ActivityLevel {
    var displayName: String {
        switch self {
        case .sedentary:        return localized("profile.activity.sedentary")
        case .lightlyActive:    return localized("profile.activity.lightly_active")
        case .moderatelyActive: return localized("profile.activity.moderately_active")
        case .veryActive:       return localized("profile.activity.very_active")
        case .extraActive:      return localized("profile.activity.extra_active")
        }
    }
}

// MARK: - BiologicalSex + displayName

extension BiologicalSex {
    var displayName: String {
        switch self {
        case .male:        return localized("profile.sex.male")
        case .female:      return localized("profile.sex.female")
        case .unspecified: return localized("profile.sex.unspecified")
        }
    }
}
