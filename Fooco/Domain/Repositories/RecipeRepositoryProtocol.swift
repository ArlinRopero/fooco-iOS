// MARK: - RecipeRepositoryProtocol.swift

import Foundation

// MARK: - RecipeRepositoryProtocol

protocol RecipeRepositoryProtocol: Sendable {

    /// Devuelve todas las recetas del usuario autenticado.
    func getMyRecipes() async throws -> [Recipe]

    /// Devuelve recetas públicas (explorador — solo Premium puede publicar).
    func getPublicRecipes(limit: Int) async throws -> [Recipe]

    /// Guarda o actualiza una receta.
    func saveRecipe(_ recipe: Recipe) async throws

    /// Elimina una receta por su ID.
    func deleteRecipe(id: String) async throws
}
