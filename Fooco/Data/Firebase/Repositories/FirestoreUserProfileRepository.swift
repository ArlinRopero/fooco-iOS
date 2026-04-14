// MARK: - FirestoreUserProfileRepository.swift
//
// Implementación Firestore de UserProfileRepositoryProtocol.
//
// Ruta del documento:
//   users/{uid}/profile   ← documento único por usuario
//
// ¿Por qué no una subcolección?
// El perfil es un único documento — no es una colección de items.
// Firestore recomienda documentos únicos para objetos de configuración.

import FirebaseFirestore
import FirebaseAuth
import Foundation

// MARK: - FirestoreUserProfileRepository

final class FirestoreUserProfileRepository: UserProfileRepositoryProtocol {

    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    // MARK: - UserProfileRepositoryProtocol

    func getProfile() async throws -> UserProfile? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }

        let document = try await profileRef(uid: uid).getDocument()
        guard document.exists else { return nil }

        let dto = try document.data(as: FirestoreUserProfileDTO.self)
        return dto.toDomain()
    }

    func saveProfile(_ profile: UserProfile) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirestoreRepositoryError.notAuthenticated
        }

        // Lee el tier actual antes de sobrescribir para no degradarlo
        let existingDoc = try? await profileRef(uid: uid).getDocument()
        let existingTier: SubscriptionTier = {
            guard let doc = existingDoc,
                  doc.exists,
                  let tierStr = doc.data()?["subscriptionTier"] as? String,
                  let tier = SubscriptionTier(rawValue: tierStr)
            else { return .free }
            return tier
        }()

        var dto = FirestoreUserProfileDTO(from: profile, subscriptionTier: existingTier)
        try profileRef(uid: uid).setData(from: dto, merge: true)
    }

    // MARK: - Helpers

    private func profileRef(uid: String) -> DocumentReference {
        db.collection("users").document(uid).collection("profile").document("data")
    }
}

// MARK: - FirestoreRepositoryError

enum FirestoreRepositoryError: LocalizedError {
    case notAuthenticated
    case documentNotFound(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Debes iniciar sesión para acceder a tus datos."
        case .documentNotFound(let id):
            return "Documento no encontrado: \(id)"
        }
    }
}
