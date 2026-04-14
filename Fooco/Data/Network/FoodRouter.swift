// MARK: - FoodRouter.swift
//
// Implementa el protocolo Router para los endpoints de la
// API de USDA FoodData Central.
//
// Endpoints que cubre:
//   .search(query:pageSize:pageNumber:)  →  GET /foods/search?query=apple&pageSize=10&pageNumber=1
//   .detail(fdcId:)                      →  GET /food/123456
//
// ¿Quién inyecta el api_key?
// El NetworkManager — no el Router. Así la key no aparece
// en ningún endpoint y se puede rotar en un solo lugar.
//
// Documentación de la API:
//   https://fdc.nal.usda.gov/api-guide

import Foundation

// MARK: - Constantes privadas de FoodRouter

private enum Defaults {
    /// Resultados por página en búsquedas.
    /// 10 es suficiente para la carga inicial — el usuario puede pedir más con scroll.
    static let pageSize   = 10
    static let pageNumber = 1
}

// MARK: - FoodRouter

/// Endpoints de la API USDA FoodData Central.
enum FoodRouter: Router {

    // MARK: Casos (endpoints)

    /// Busca alimentos por texto.
    ///
    /// - Parameters:
    ///   - query:      Término de búsqueda. Ejemplo: "avocado", "brown rice".
    ///   - pageSize:   Cantidad de resultados por página (máx 200).
    ///   - pageNumber: Número de página (1-indexed).
    case search(query: String, pageSize: Int = Defaults.pageSize, pageNumber: Int = Defaults.pageNumber)

    /// Obtiene el detalle nutricional completo de un alimento.
    ///
    /// - Parameter fdcId: ID único del alimento en la base de datos USDA.
    case detail(fdcId: Int)

    // MARK: - Router conformance

    var baseURL: String {
        APIConfig.usdaBaseURL
    }

    var path: String {
        switch self {
        case .search:
            return "/foods/search"

        case .detail(let fdcId):
            return "/food/\(fdcId)"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var headers: [String: String]? {
        nil
    }

    /// ⚠️  api_key NO va aquí — el NetworkManager lo agrega.
    var parameters: [String: Any]? {
        switch self {
        case .search(let query, let pageSize, let pageNumber):
            return [
                "query"      : query,
                "pageSize"   : pageSize,
                "pageNumber" : pageNumber,
                // dataType filtra solo alimentos con datos nutricionales completos.
                "dataType"   : "Foundation,SR Legacy"
            ]

        case .detail:
            return nil
        }
    }
}
