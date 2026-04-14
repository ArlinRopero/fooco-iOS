// MARK: - UserProfileRepository.swift
//
// Implementación del repositorio de perfil usando SwiftData.
//
// Mismo patrón que FoodLogRepository: @ModelActor con su propio ModelContext.
//
// ¿Por qué fetch + update en lugar de delete + insert?
// Mantener el mismo registro evita generar history entries innecesarios
// en SwiftData y conserva el mismo UUID si se reusa en el futuro.
// Si no existe, se crea uno nuevo.

import SwiftData
import Foundation

// MARK: - UserProfileRepository

@ModelActor
actor UserProfileRepository: UserProfileRepositoryProtocol {

    // MARK: - UserProfileRepositoryProtocol

    func getProfile() async throws -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfileModel>()
        let models = try modelContext.fetch(descriptor)
        return models.first.map(UserProfileMapper.toDomain)
    }

    func saveProfile(_ profile: UserProfile) async throws {
        let descriptor = FetchDescriptor<UserProfileModel>()
        let existing = try modelContext.fetch(descriptor).first

        if let existing {
            UserProfileMapper.update(existing, from: profile)
        } else {
            let model = UserProfileMapper.toModel(profile)
            modelContext.insert(model)
        }

        try modelContext.save()
    }
}
