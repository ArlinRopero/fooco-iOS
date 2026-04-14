// MARK: - FoodRepositoryProtocol.swift
//
// Contrato de acceso a datos de alimentos.
//
// Domain (círculo interior) define QUÉ operaciones existen.
// Data   (círculo exterior) define CÓMO se implementan.
//
// Flujo:
//   UseCase → FoodRepositoryProtocol (Domain)
//                    ↑ conforma
//              FoodRepository (Data) → NetworkManager → USDA API

import Foundation

// MARK: - FoodSearchPage

/// Página de resultados de búsqueda con información de paginación.
///
/// ¿Por qué aquí y no en el UseCase?
/// El Repository devuelve esta estructura directamente.
/// Al definirla en Domain, tanto el protocolo como los UseCases
/// la ven sin depender de la capa Data.
struct FoodSearchPage: Sendable {

    /// Alimentos de esta página.
    let foods: [Food]

    /// Número de página actual (1-indexed).
    let currentPage: Int

    /// Total de páginas disponibles para esta búsqueda.
    let totalPages: Int

    /// true si hay más páginas que cargar.
    var hasMore: Bool { currentPage < totalPages }
}

// MARK: - FoodRepositoryProtocol

/// Contrato de acceso a datos de alimentos.
///
/// Todas las operaciones son `async throws`:
/// - `async`  → operaciones potencialmente costosas (red, disco)
/// - `throws` → propagan `APIError` o cualquier error de la fuente de datos
protocol FoodRepositoryProtocol: Sendable {

    /// Busca alimentos por texto libre con soporte de paginación.
    ///
    /// - Parameters:
    ///   - query:      Término de búsqueda. Ej: "avocado", "whole wheat bread"
    ///   - pageSize:   Número de resultados por página.
    ///   - pageNumber: Página a cargar (1-indexed).
    /// - Returns: `FoodSearchPage` con los alimentos y metadatos de paginación.
    /// - Throws: `APIError` si la petición falla.
    func searchFoods(query: String, pageSize: Int, pageNumber: Int) async throws -> FoodSearchPage

    /// Obtiene el detalle ampliado de un alimento (categoría, porciones, nutrientes extendidos).
    ///
    /// - Parameter fdcId: Identificador único del alimento en la base de datos USDA.
    /// - Returns: `FoodDetail` con toda la información disponible en el endpoint de detalle.
    /// - Throws: `APIError` si el alimento no existe o la petición falla.
    func getFoodDetail(fdcId: Int) async throws -> FoodDetail
}
