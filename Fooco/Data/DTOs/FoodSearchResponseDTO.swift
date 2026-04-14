// MARK: - FoodSearchResponseDTO.swift
//
// ¿Qué es un DTO?
// Data Transfer Object — un struct que mapea 1:1 el JSON de la API.
// Su único trabajo es decodificar. No tiene lógica de negocio.
//
// ¿Por qué no usar el modelo de dominio directamente?
// Porque el JSON de la API tiene nombres, estructura y tipos que
// no siempre son convenientes para la app:
//   API: "description" → App: "name"
//   API: nutrients como array plano → App: objeto con propiedades nombradas
//
// El DTO absorbe la fealdad del JSON. El modelo de dominio (Food)
// expone solo lo que la UI necesita — limpio y tipado.
//
// Flujo:
//   JSON  →  (JSONDecoder)  →  FoodSearchResponseDTO  →  (mapper)  →  [Food]
//
// Este DTO corresponde al endpoint:
//   GET /foods/search?query=apple&pageSize=20&api_key=xxx

import Foundation

// MARK: - FoodSearchResponseDTO

/// Respuesta completa del endpoint de búsqueda.
struct FoodSearchResponseDTO: Codable, Sendable {

    /// Total de resultados que existen en la base de datos para la búsqueda.
    /// Puede ser mucho mayor que `foods.count` (que está limitado por pageSize).
    let totalHits: Int

    /// Página actual de resultados.
    let currentPage: Int

    /// Total de páginas disponibles para esta búsqueda.
    let totalPages: Int

    /// Lista de alimentos que coinciden con la búsqueda en esta página.
    let foods: [FoodSearchItemDTO]
}

// MARK: - FoodSearchItemDTO

/// Un alimento individual dentro de los resultados de búsqueda.
///
/// Usa el formato "abridged" (resumido) de la API — los nutrientes
/// vienen como array plano con nombre y valor, no como objetos anidados.
struct FoodSearchItemDTO: Codable, Sendable {

    /// ID único del alimento en la base de datos de USDA.
    /// Se usa para llamar al endpoint de detalle: GET /food/{fdcId}
    let fdcId: Int

    /// Nombre del alimento. Ej: "Avocado, raw" o "Bread, whole-wheat"
    let description: String

    /// Tipo de base de datos. Ej: "Foundation", "SR Legacy", "Branded"
    /// Foundation y SR Legacy tienen datos nutricionales más completos.
    let dataType: String?

    /// Fecha en que se publicó este registro en la base de datos.
    let publicationDate: String?

    /// Marca propietaria (solo para alimentos "Branded").
    /// Para Foundation y SR Legacy siempre es nil.
    let brandOwner: String?

    /// Nutrientes en formato resumido.
    /// En búsqueda la API devuelve pocos nutrientes (los principales).
    /// Para el perfil nutricional completo se usa el endpoint de detalle.
    let foodNutrients: [SearchFoodNutrientDTO]?
}

// MARK: - SearchFoodNutrientDTO

/// Nutriente en el contexto de búsqueda (formato abridged).
///
/// La API de búsqueda devuelve campos con nombres distintos al endpoint de detalle.
/// Estructura real confirmada contra la API de USDA FoodData Central v1:
///
/// ```json
/// {
///   "nutrientId": 1008,
///   "nutrientName": "Energy",
///   "nutrientNumber": "208",
///   "unitName": "KCAL",
///   "value": 160.0,
///   "rank": 300
/// }
/// ```
///
/// Nota clave: `nutrientId` (1008) es el ID largo; `nutrientNumber` ("208") es el código corto como String.
/// Para comparar en el mapper se usa `nutrientId` (coincide con `NutrientID`).
struct SearchFoodNutrientDTO: Codable, Sendable {

    /// ID USDA del nutriente (formato largo). Ej: 1008 → Energía, 1003 → Proteína.
    let nutrientId: Int?

    /// Nombre legible del nutriente. Ej: "Energy", "Protein"
    let nutrientName: String?

    /// Código corto del nutriente como String. Ej: "208" para energía. (No se usa para comparar.)
    let nutrientNumber: String?

    /// Cantidad del nutriente por 100g del alimento.
    let value: Double?

    /// Unidad de medida. Ej: "KCAL", "G", "MG"
    let unitName: String?
}
