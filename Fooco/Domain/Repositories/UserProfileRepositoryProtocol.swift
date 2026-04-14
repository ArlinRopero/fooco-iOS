// MARK: - UserProfileRepositoryProtocol.swift
//
// Contrato para leer y escribir el perfil del usuario.
//
// ¿Por qué un repositorio separado de FoodLogRepositoryProtocol?
// Responsabilidad única: FoodLog persiste registros de comidas,
// UserProfile persiste datos del usuario. Son conceptos distintos.
//
// ¿Por qué solo get/save y no update?
// UserProfile es un objeto de valor completo — siempre se guarda el perfil
// entero. No hay "actualizar solo el nombre" como operación del dominio;
// la UI construye el UserProfile completo y lo guarda.

import Foundation

// MARK: - UserProfileRepositoryProtocol

/// Contrato para persistir y recuperar el perfil del usuario.
protocol UserProfileRepositoryProtocol: Sendable {

    /// Devuelve el perfil guardado, o `nil` si el usuario aún no lo ha configurado.
    func getProfile() async throws -> UserProfile?

    /// Guarda (o reemplaza) el perfil del usuario.
    ///
    /// - Parameter profile: Perfil completo a persistir.
    func saveProfile(_ profile: UserProfile) async throws
}
