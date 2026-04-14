// MARK: - NetworkManager.swift
//
// ¿Qué hace este archivo?
// Es el ejecutor de todas las peticiones de red.
// Recibe un Router, construye el URLRequest, inyecta el api_key,
// ejecuta la petición y decodifica la respuesta.
//
// ¿Por qué un protocolo + implementación concreta?
// Protocolo (NetworkManagerProtocol) → los tests inyectan un mock
// Implementación (NetworkManager)    → producción usa URLSession real
//
// Concurrencia: async/await (Swift 5.5+)
// En lugar de callbacks o Combine, usamos async/await que es
// la forma moderna y más legible de manejar operaciones asíncronas.
// "await" pausa la función sin bloquear el hilo principal.
//
// Genéricos: <T: Decodable>
// Un solo método sirve para cualquier modelo que sepa decodificarse
// desde JSON. No necesitamos un método por cada tipo de respuesta.
//
// Flujo completo:
//   llamador: let results = try await networkManager.request(FoodRouter.search(...))
//       ↓
//   NetworkManager.request<T>()
//       ↓ router.asURLRequest() → URLRequest base
//       ↓ inyecta ?api_key=xxx
//       ↓ URLSession.data(for: request)
//       ↓ valida status code (200-299)
//       ↓ JSONDecoder().decode(T.self, from: data)
//       ↓ retorna T  (o lanza APIError)

import Foundation

// MARK: - NetworkManagerProtocol

/// Contrato del manager de red.
///
/// Tener un protocolo permite que en los tests se inyecte
/// un `MockNetworkManager` que devuelve datos fijos sin
/// tocar la red real.
protocol NetworkManagerProtocol {
    func request<T: Decodable>(_ router: any Router) async throws -> T
}

// MARK: - NetworkManager

/// Implementación real del manager de red.
///
/// Usa `actor` para garantizar que su estado interno
/// (la sesión de URLSession) sea accedido de forma segura
/// desde múltiples tareas concurrentes sin data races.
actor NetworkManager: NetworkManagerProtocol {

    // MARK: - Singleton

    /// Instancia compartida para uso en producción.
    ///
    /// Usamos singleton aquí porque URLSession es costosa de crear
    /// y queremos reutilizar la misma configuración en toda la app.
    /// En tests, inyectamos una instancia nueva directamente.
    static let shared = NetworkManager()

    // MARK: - Propiedades privadas

    /// Sesión de red configurada con timeout razonable.
    private let session: URLSession

    /// Decodificador JSON reutilizable.
    /// Se crea una sola vez porque es costoso de inicializar.
    private let decoder: JSONDecoder

    /// Closure que provee el api_key en tiempo de ejecución.
    ///
    /// ¿Por qué un closure en lugar de leer APIConfig directamente?
    /// Porque así los tests pueden inyectar una key falsa sin tocar
    /// la configuración real del proyecto (ni necesitar Info.plist).
    /// Es el patrón de Inyección de Dependencias aplicado a un valor.
    ///
    /// Producción: lee de APIConfig → Bundle.main → Secrets.xcconfig
    /// Tests:      devuelve "test-api-key" sin leer nada real
    private let apiKeyProvider: @Sendable () async -> String

    // MARK: - Init

    /// - Parameters:
    ///   - session: URLSession a usar. Tests inyectan una con MockURLProtocol.
    ///   - apiKeyProvider: Cómo obtener el api_key. Tests inyectan un valor fijo.
    init(
        session: URLSession = .shared,
        apiKeyProvider: @Sendable @escaping () async -> String = {
            await MainActor.run { APIConfig.usdaKey }
        }
    ) {
        self.session = session
        self.apiKeyProvider = apiKeyProvider

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Request

    /// Ejecuta una petición de red y decodifica la respuesta.
    ///
    /// - Parameter router: El endpoint a llamar (ej. `FoodRouter.search(...)`).
    /// - Returns: El modelo decodificado de tipo `T`.
    /// - Throws: `APIError` con el caso correspondiente al fallo.
    ///
    /// Uso:
    /// ```swift
    /// let response: FoodSearchResponse = try await NetworkManager.shared.request(
    ///     FoodRouter.search(query: "apple")
    /// )
    /// ```
    func request<T: Decodable>(_ router: any Router) async throws -> T {

        // 1. Construir el URLRequest base desde el Router
        var urlRequest = try await router.asURLRequest()

        // 2. Inyectar el api_key como query param
        urlRequest = try await injectAPIKey(into: urlRequest, for: router)

        // 3. Log del request (URL sin api_key para no exponer la clave)
        let startTime = Date()
        debugLogRequest(urlRequest)

        // 4. Ejecutar la petición
        let (data, response) = try await session.data(for: urlRequest)

        // 5. Log de la respuesta
        let elapsed = Date().timeIntervalSince(startTime)
        debugLogResponse(response, data: data, elapsed: elapsed)

        // 6. Validar el código de respuesta HTTP
        try validate(response: response)

        // 7. Decodificar el JSON en el modelo esperado
        return try decode(data)
    }

    // MARK: - Helpers privados

    /// Inyecta el api_key correcto según la API que usa el Router.
    ///
    /// Cada API puede tener su propio mecanismo de autenticación.
    /// Centralizarlo aquí evita que los Routers sepan de credenciales.
    ///
    /// Es `async` porque `APIConfig.usdaKey` lee `Bundle.main.infoDictionary`,
    /// que en Swift 6 está aislado al `@MainActor`. Usamos `MainActor.run {}`
    /// para pedirle al hilo principal que lea el valor de forma segura,
    /// y luego seguimos en el actor de NetworkManager.
    private func injectAPIKey(into request: URLRequest, for router: any Router) async throws -> URLRequest {
        guard var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }

        // Obtenemos la key a través del provider inyectado.
        // En producción llama a APIConfig; en tests devuelve un valor fijo.
        let key = await apiKeyProvider()

        // La USDA espera el api_key como query param
        // Si en el futuro una API usa header (Bearer token), se agrega otro case aquí
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "api_key", value: key))
        components.queryItems = queryItems

        guard let url = components.url else { throw APIError.invalidURL }

        var newRequest = request
        newRequest.url = url
        return newRequest
    }

    /// Valida que el código HTTP esté en el rango 200-299.
    ///
    /// - Throws: `APIError.httpError(statusCode:)` si la respuesta no es exitosa.
    private func validate(response: URLResponse) throws {
        // Casteamos a HTTPURLResponse para acceder al statusCode
        // (URLResponse es la clase base, no tiene statusCode)
        guard let http = response as? HTTPURLResponse else { return }

        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode)
        }
    }

    // MARK: - Debug logging

    private func debugLogRequest(_ request: URLRequest) {
        #if DEBUG
        guard let url = request.url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }

        // Base URL: esquema + host
        let baseURL = "\(components.scheme ?? "")://\(components.host ?? "")"

        // Endpoint: el path
        let endpoint = components.path.isEmpty ? "/" : components.path

        // Parámetros: ocultar api_key
        let params = (components.queryItems ?? [])
            .map { item in
                item.name == "api_key" ? "api_key=***" : "\(item.name)=\(item.value ?? "")"
            }
            .joined(separator: "\n│    ")

        // Headers
        let headers = (request.allHTTPHeaderFields ?? [:])
            .map { "\($0.key): \($0.value)" }
            .sorted()
            .joined(separator: "\n│    ")

        print("""
        ┌─ 🌐 REQUEST ───────────────────────────────
        │  Método   : \(request.httpMethod ?? "GET")
        │  Base URL : \(baseURL)
        │  Endpoint : \(endpoint)
        │  Params   : \(params.isEmpty ? "(ninguno)" : "\n│    \(params)")
        │  Headers  : \(headers.isEmpty ? "(ninguno)" : "\n│    \(headers)")
        └────────────────────────────────────────────
        """)
        #endif
    }

    private func debugLogResponse(_ response: URLResponse, data: Data, elapsed: TimeInterval) {
        #if DEBUG
        let http = response as? HTTPURLResponse
        let statusCode = http?.statusCode ?? 0
        let statusIcon = (200...299).contains(statusCode) ? "✅" : "❌"
        let ms = Int(elapsed * 1000)
        let kb = String(format: "%.1f", Double(data.count) / 1024)

        // Pretty-print del JSON — si falla el parse mostramos el raw string
        let jsonBody: String
        if let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            // Indentamos cada línea con │ para que quede dentro del bloque
            jsonBody = prettyString
                .split(separator: "\n", omittingEmptySubsequences: false)
                .map { "│  \($0)" }
                .joined(separator: "\n")
        } else {
            jsonBody = "│  \(String(data: data, encoding: .utf8) ?? "(no decodificable)")"
        }

        print("""
        └─ \(statusIcon) RESPONSE ──────────────────────────────
        │  Status : \(statusCode)
        │  Tiempo : \(ms)ms
        │  Tamaño : \(kb) KB (\(data.count) bytes)
        │  Body   :
        \(jsonBody)
        ────────────────────────────────────────────
        """)
        #endif
    }

    /// Decodifica `Data` en el modelo `T`.
    ///
    /// - Throws: `APIError.noData` si data está vacío.
    ///           `APIError.decodingError` si el JSON no coincide con el modelo.
    private func decode<T: Decodable>(_ data: Data) throws -> T {
        guard !data.isEmpty else {
            throw APIError.noData
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
