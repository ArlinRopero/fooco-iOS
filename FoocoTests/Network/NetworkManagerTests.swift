// MARK: - NetworkManagerTests.swift
//
// ¿Qué probamos aquí?
// El comportamiento de NetworkManager ante distintas respuestas
// del servidor — sin tocar la red real.
//
// ¿Cómo?
// MockURLProtocol intercepta URLSession y devuelve respuestas
// predefinidas. NetworkManager no sabe que no hay red real.
//
// Casos que cubrimos:
//   ✅ Respuesta 200 con JSON válido → decodifica correctamente
//   ✅ Respuesta 404               → lanza httpError(404)
//   ✅ Respuesta 500               → lanza httpError(500)
//   ✅ Datos vacíos                → lanza noData
//   ✅ JSON inválido               → lanza decodingError
//   ✅ api_key inyectada           → aparece en la URL del request

import Testing
import Foundation
@testable import Fooco

// MARK: - Modelo de prueba

/// Struct mínimo para probar la decodificación genérica.
/// No necesitamos el modelo real de USDA para testear NetworkManager.
private struct TestFood: Codable, Equatable {
    let id: Int
    let name: String
}

// MARK: - NetworkManagerTests

// .serialized hace que los tests de este suite corran uno a la vez.
// Es necesario porque MockURLProtocol.requestHandler es un static var
// compartido — si dos tests corren en paralelo se pisan mutuamente.
@Suite("NetworkManager", .serialized)
struct NetworkManagerTests {

    // MARK: - Helpers

    /// Crea un NetworkManager con URLSession mockeada y api_key fija.
    ///
    /// Los tests no necesitan Info.plist ni Secrets.xcconfig porque
    /// inyectamos directamente una key falsa — la red está mockeada
    /// de todas formas, así que el valor no importa.
    private func makeSUT() -> NetworkManager {
        NetworkManager(
            session: MockURLProtocol.makeSession(),
            apiKeyProvider: { "test-api-key" }
        )
    }

    /// Limpia el handler después de cada test.
    /// Sin esto, un handler de un test anterior podría interferir
    /// con el siguiente si algo sale mal en el orden de ejecución.
    private func tearDown() {
        MockURLProtocol.requestHandler = nil
    }

    /// Convierte un Encodable a Data JSON.
    private func encode<T: Encodable>(_ value: T) throws -> Data {
        try JSONEncoder().encode(value)
    }

    // MARK: - Happy path

    @Test("Decodifica correctamente una respuesta 200 con JSON válido")
    func decodesValidResponse() async throws {
        defer { tearDown() }
        // Arrange
        let expected = TestFood(id: 1, name: "Apple")
        let data = try encode(expected)

        MockURLProtocol.requestHandler = { _ in
            (MockURLProtocol.makeResponse(statusCode: 200), data)
        }

        let sut = makeSUT()

        // Act
        let result: TestFood = try await sut.request(FoodRouter.search(query: "apple"))

        // Assert
        #expect(result == expected)
    }

    // MARK: - Errores HTTP

    @Test("Lanza httpError cuando el servidor devuelve 404")
    func throws404Error() async throws {
        defer { tearDown() }
        // Arrange
        MockURLProtocol.requestHandler = { _ in
            (MockURLProtocol.makeResponse(statusCode: 404), Data())
        }

        let sut = makeSUT()

        // Assert — verificamos que lanza el error correcto
        await #expect(throws: APIError.httpError(statusCode: 404)) {
            let _: TestFood = try await sut.request(FoodRouter.search(query: "test"))
        }
    }

    @Test("Lanza httpError cuando el servidor devuelve 500")
    func throws500Error() async throws {
        defer { tearDown() }
        MockURLProtocol.requestHandler = { _ in
            (MockURLProtocol.makeResponse(statusCode: 500), Data())
        }

        let sut = makeSUT()

        await #expect(throws: APIError.httpError(statusCode: 500)) {
            let _: TestFood = try await sut.request(FoodRouter.search(query: "test"))
        }
    }

    // MARK: - Errores de datos

    @Test("Lanza noData cuando la respuesta está vacía")
    func throwsNoDataOnEmptyResponse() async throws {
        defer { tearDown() }
        // Arrange — respuesta 200 pero sin cuerpo
        MockURLProtocol.requestHandler = { _ in
            (MockURLProtocol.makeResponse(statusCode: 200), Data())
        }

        let sut = makeSUT()

        // Assert
        await #expect(throws: APIError.noData) {
            let _: TestFood = try await sut.request(FoodRouter.search(query: "test"))
        }
    }

    @Test("Lanza decodingError cuando el JSON no coincide con el modelo")
    func throwsDecodingErrorOnInvalidJSON() async throws {
        defer { tearDown() }
        // Arrange — JSON válido pero estructura incorrecta para TestFood
        let wrongJSON = #"{"unexpected_field": true}"#.data(using: .utf8)!

        MockURLProtocol.requestHandler = { _ in
            (MockURLProtocol.makeResponse(statusCode: 200), wrongJSON)
        }

        let sut = makeSUT()

        // Act & Assert — esperamos decodingError (sin importar el error subyacente)
        var didThrowDecodingError = false
        do {
            let _: TestFood = try await sut.request(FoodRouter.search(query: "test"))
        } catch APIError.decodingError {
            didThrowDecodingError = true
        } catch {
            // Cualquier otro error es un fallo
        }

        #expect(didThrowDecodingError)
    }

    // MARK: - Inyección del api_key

    @Test("El api_key se inyecta como query param en la URL")
    func apiKeyIsInjectedInURL() async throws {
        defer { tearDown() }
        // Arrange
        var capturedRequest: URLRequest?
        let data = try encode(TestFood(id: 1, name: "Test"))

        MockURLProtocol.requestHandler = { request in
            capturedRequest = request  // capturamos el request real
            return (MockURLProtocol.makeResponse(statusCode: 200), data)
        }

        let sut = makeSUT()

        // Act
        let _: TestFood = try await sut.request(FoodRouter.search(query: "test"))

        // Assert — la URL final debe contener api_key
        let urlString = capturedRequest?.url?.absoluteString ?? ""
        #expect(urlString.contains("api_key="))
    }

    @Test("El api_key NO está en los parámetros del Router")
    func apiKeyIsNotInRouterParameters() {
        // El Router no debe saber de credenciales
        let router = FoodRouter.search(query: "apple")
        let hasApiKey = router.parameters?.keys.contains("api_key") ?? false
        #expect(!hasApiKey)
    }
}

// APIError: Equatable está definido directamente en APIError.swift.
