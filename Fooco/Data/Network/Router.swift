// MARK: - Router.swift
//
// ¿Qué hace este archivo?
// Define el PROTOCOLO que todo endpoint de la app debe implementar.
//
// ¿Qué es un protocolo en este contexto?
// Es un contrato. Le dice al compilador: "cualquier cosa que se llame
// Router DEBE saber responder estas preguntas sobre sí misma":
//   - ¿Cuál es tu URL base?
//   - ¿Cuál es tu path?
//   - ¿Qué método HTTP usas?
//   - ¿Qué headers llevas?
//   - ¿Qué parámetros/body llevas?
//
// ¿Por qué un protocolo y no una clase base?
// Con un protocolo + enum (en FoodRouter) ganamos:
//   ✅ El compilador exige que cada endpoint implemente todo.
//   ✅ Podemos agregar una segunda API (ej. RecipeRouter) sin tocar
//      el NetworkManager — solo conforma al mismo protocolo.
//   ✅ Fácil de mockear en tests: basta crear un tipo de prueba
//      que conforme a Router.
//
// Patrón: Protocol-Oriented Programming (POP)
// Apple promueve este estilo en Swift sobre la herencia clásica.
// En lugar de "hereda de NetworkBase", se dice "conforma a Router".
//
// Flujo completo:
//   FoodRouter (enum) conforma a Router
//       ↓  provee baseURL, path, method, headers, parameters
//   NetworkManager.request(router:)
//       ↓  llama a router.asURLRequest()
//   URLRequest listo para URLSession

import Foundation

// MARK: - Router (protocolo)

/// Contrato que debe cumplir cualquier endpoint de la app.
///
/// - `Sendable`: permite pasar routers entre actores (ej. de un test al
///   NetworkManager actor) sin warnings de concurrencia en Swift 6.
///   Los enums con valores asociados `Sendable` (String, Int) conforman
///   automáticamente a `Sendable` sin código extra.
protocol Router: Sendable {

    // MARK: Propiedades requeridas

    /// Dominio raíz de la API.
    /// Ejemplo: "https://api.spoonacular.com"
    ///
    /// Se separa del path para poder cambiar de entorno fácilmente
    /// (desarrollo, staging, producción) sin tocar cada endpoint.
    var baseURL: String { get }

    /// Ruta específica del endpoint, relativa al baseURL.
    /// Ejemplo: "/food/search"
    ///
    /// No incluye query params — esos van en `parameters`.
    var path: String { get }

    /// Método HTTP del endpoint (GET, POST, etc.).
    /// Viene del enum HTTPMethod que ya creamos.
    var method: HTTPMethod { get }

    /// Headers HTTP adicionales para esta petición.
    /// Ejemplo: ["Content-Type": "application/json"]
    ///
    /// `nil` si el endpoint no necesita headers especiales.
    /// El NetworkManager añadirá los headers comunes por separado.
    var headers: [String: String]? { get }

    /// Parámetros de la petición.
    ///
    /// - Para GET: se convierten en query params → ?query=pizza&number=10
    /// - Para POST/PUT/PATCH: van en el body como JSON.
    ///
    /// `nil` si el endpoint no lleva parámetros.
    var parameters: [String: Any]? { get }
}

// MARK: - Extensión con implementación por defecto

extension Router {

    /// Construye el `URLRequest` listo para pasarle a URLSession.
    ///
    /// Este método vive en la extensión para que TODOS los Routers
    /// lo hereden automáticamente — ninguno necesita implementarlo.
    /// Solo necesitan declarar baseURL, path, method, etc.
    ///
    /// - Throws: `APIError.invalidURL` si la URL no se puede construir.
    /// - Returns: `URLRequest` configurado con método, headers y params.
    func asURLRequest() throws -> URLRequest {

        // 1. Construir la URL base + path
        guard var components = URLComponents(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        // 2. Si es GET, los parámetros van como query items en la URL
        //    Ejemplo: ?query=pizza&number=10&apiKey=abc123
        if method == .get, let parameters {
            components.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }

        // 3. Validar que la URL final sea construible
        guard let url = components.url else {
            throw APIError.invalidURL
        }

        // 4. Crear el request con la URL
        var request = URLRequest(url: url)

        // 5. Asignar el método HTTP ("GET", "POST", etc.)
        request.httpMethod = method.rawValue

        // 6. Asignar headers si los hay
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // 7. Si NO es GET y hay parámetros, serializar como JSON en el body
        if method != .get, let parameters {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        }

        return request
    }
}
