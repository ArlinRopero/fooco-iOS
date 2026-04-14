// MARK: - FirestoreRecipeRepository.swift
//
// Implementación Firestore de RecipeRepositoryProtocol.
//
// Rutas:
//   Recetas propias:   users/{uid}/recipes/{recipeId}
//   Recetas públicas:  collectionGroup("recipes") where isPublic == true
//
// Freemium:
//   Free    → solo crea/lee sus propias recetas
//   Premium → puede marcar recetas como isPublic y acceder al explorador

import FirebaseFirestore
import FirebaseAuth
import Foundation

// MARK: - FirestoreRecipeRepository

final class FirestoreRecipeRepository: RecipeRepositoryProtocol {

    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    // MARK: - RecipeRepositoryProtocol

    func getMyRecipes() async throws -> [Recipe] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

        let snapshot = try await recipesRef(uid: uid)
            .order(by: "updatedAt", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: FirestoreRecipeDTO.self)
        }.map { $0.toDomain(authorId: uid) }
    }

    func getPublicRecipes(limit: Int) async throws -> [Recipe] {
        // Collection group query — requiere índice en Firebase Console
        let snapshot = try await db.collectionGroup("recipes")
            .whereField("isPublic", isEqualTo: true)
            .order(by: "updatedAt", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { doc -> Recipe? in
            guard let dto = try? doc.data(as: FirestoreRecipeDTO.self) else { return nil }
            // El authorId se infiere del path: users/{uid}/recipes/{id}
            let pathComponents = doc.reference.path.components(separatedBy: "/")
            let authorId = pathComponents.count >= 2 ? pathComponents[1] : "unknown"
            return dto.toDomain(authorId: authorId)
        }
    }

    func saveRecipe(_ recipe: Recipe) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirestoreRepositoryError.notAuthenticated
        }

        let dto = FirestoreRecipeDTO(recipe: recipe)
        let docRef = recipe.id.isEmpty
            ? recipesRef(uid: uid).document()
            : recipesRef(uid: uid).document(recipe.id)

        try docRef.setData(from: dto, merge: false)
    }

    func deleteRecipe(id: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirestoreRepositoryError.notAuthenticated
        }
        try await recipesRef(uid: uid).document(id).delete()
    }

    // MARK: - Helpers

    private func recipesRef(uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("recipes")
    }
}
