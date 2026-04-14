// MARK: - FirestoreUserProfileDTO.swift
//
// Representa el documento Firestore en:
//   users/{uid}/profile
//
// ¿Por qué un DTO separado del dominio?
// Firestore usa Timestamp, el dominio usa Date.
// Firestore usa [String] para condiciones, el dominio usa Set<HealthCondition>.
// Este DTO hace la traducción sin contaminar la capa de dominio.
//
// Modelo Freemium:
//   subscriptionTier: "free" | "premium"
//   subscriptionExpiresAt: nil si es free

import FirebaseFirestore
import Foundation

// MARK: - SubscriptionTier

enum SubscriptionTier: String, Codable {
    case free    = "free"
    case premium = "premium"
}

// MARK: - FirestoreUserProfileDTO

struct FirestoreUserProfileDTO: Codable {

    // MARK: - Datos personales

    @DocumentID var documentId: String?
    var name: String?
    var biologicalSex: String
    var birthYear: Int?
    var weightKg: Double?
    var heightCm: Double?
    var activityLevel: String
    var dailyCalorieGoal: Int?

    /// Condiciones de salud como array de rawValues.
    /// Ejemplo: ["anemia", "diabetes2"]
    var healthConditions: [String]

    // MARK: - Freemium

    var subscriptionTier: String
    var subscriptionExpiresAt: Timestamp?

    // MARK: - Metadata

    var updatedAt: Timestamp

    // MARK: - CodingKeys (para evitar colisión con @DocumentID)

    enum CodingKeys: String, CodingKey {
        case name, biologicalSex, birthYear, weightKg, heightCm
        case activityLevel, dailyCalorieGoal, healthConditions
        case subscriptionTier, subscriptionExpiresAt, updatedAt
    }

    // MARK: - Domain → DTO

    init(from profile: UserProfile, subscriptionTier: SubscriptionTier = .free) {
        self.name                  = profile.name
        self.biologicalSex         = profile.biologicalSex.rawValue
        self.birthYear             = profile.birthYear
        self.weightKg              = profile.weightKg
        self.heightCm              = profile.heightCm
        self.activityLevel         = profile.activityLevel.rawValue
        self.dailyCalorieGoal      = profile.dailyCalorieGoal
        self.healthConditions      = profile.healthConditions.map(\.rawValue).sorted()
        self.subscriptionTier      = subscriptionTier.rawValue
        self.subscriptionExpiresAt = nil
        self.updatedAt             = Timestamp(date: Date())
    }

    // MARK: - DTO → Domain

    func toDomain() -> UserProfile {
        UserProfile(
            id: UUID(),
            name: name,
            biologicalSex: BiologicalSex(rawValue: biologicalSex) ?? .unspecified,
            birthYear: birthYear,
            weightKg: weightKg,
            heightCm: heightCm,
            activityLevel: ActivityLevel(rawValue: activityLevel) ?? .sedentary,
            dailyCalorieGoal: dailyCalorieGoal,
            healthConditions: Set(healthConditions.compactMap(HealthCondition.init(rawValue:)))
        )
    }

    var isPremium: Bool {
        guard subscriptionTier == SubscriptionTier.premium.rawValue else { return false }
        if let expires = subscriptionExpiresAt {
            return expires.dateValue() > Date()
        }
        return true
    }

    /// Días de retención del historial de alimentos según el tier.
    var historyRetentionDays: Int {
        isPremium ? 30 : 7
    }
}
