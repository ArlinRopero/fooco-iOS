// MARK: - MockNetworkManager.swift
//
// Mock de NetworkManager para tests del repositorio.
//
// ¿Por qué un mock del NetworkManager y no del repositorio?
// Porque aquí estamos testeando FoodRepository.
// FoodRepository depende de NetworkManagerProtocol → mockeamos eso.
//
// El mock guarda qué router recibió (para verificar que el repositorio
// construye los routers correctamente) y puede configurarse para
// devolver datos o lanzar errores.
//
// Patrón: "Spy + Stub"
//   Spy  → registra las llamadas recibidas (lastRouter)
//   Stub → devuelve respuestas predefinidas (responseData / errorToThrow)

import Foundation
@testable import Fooco

// MARK: - MockNetworkManager

/// Mock de `NetworkManagerProtocol` para tests de repositorios y use cases.
///
/// Configuración:
/// ```swift
/// let mock = MockNetworkManager()
/// mock.responseData = someEncodableObject  // éxito
/// mock.errorToThrow = APIError.noData      // fallo
/// ```
final class MockNetworkManager: NetworkManagerProtocol, @unchecked Sendable {

    // MARK: - Configuración del mock

    /// Respuesta que devolverá en la próxima llamada.
    /// Debe ser `Encodable` para convertirlo en Data y decodificarlo al tipo T esperado.
    ///
    /// ¿Por qué encodar/decodear en lugar de devolver T directamente?
    /// Porque el protocolo retorna `T: Decodable` genérico — no podemos
    /// almacenar un `T` sin saber su tipo en tiempo de compilación.
    /// Encodar a JSON y decodear simula el comportamiento real de la red.
    var responseData: (any Encodable)?

    /// Error que lanzará en la próxima llamada (si está configurado).
    /// Tiene prioridad sobre `responseData`.
    var errorToThrow: Error?

    // MARK: - Registro de llamadas (Spy)

    /// Último router recibido. Útil para verificar que el repositorio
    /// construye el router correcto para cada operación.
    private(set) var lastRouter: (any Router)?

    /// Número total de llamadas recibidas.
    private(set) var callCount: Int = 0

    // MARK: - NetworkManagerProtocol

    func request<T: Decodable>(_ router: any Router) async throws -> T {
        // Registrar la llamada (comportamiento Spy)
        lastRouter = router
        callCount += 1

        // Si hay error configurado, lanzarlo primero
        if let error = errorToThrow {
            throw error
        }

        // Si hay respuesta, encodar → Data → decodear como T
        guard let response = responseData else {
            throw APIError.noData
        }

        // Encodamos el mock a JSON y luego decodificamos al tipo esperado.
        // Esto garantiza que el mock se comporta igual que el NetworkManager real.
        let data = try JSONEncoder().encode(response)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
