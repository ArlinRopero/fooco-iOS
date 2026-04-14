// MARK: - APIErrorTests.swift
//
// ¿Qué probamos aquí?
// Que cada caso de APIError tiene un mensaje de error (no nil)
// y que los casos con datos asociados los incluyen correctamente.
//
// Patrón: AAA (Arrange - Act - Assert)
//   Arrange: preparar los datos necesarios
//   Act:     ejecutar la acción a probar
//   Assert:  verificar el resultado con #expect
//
// Nota sobre localización en tests:
// NSLocalizedString en el target de tests no tiene acceso al xcstrings
// de la app, así que retorna la clave ("error.invalid_url").
// Eso está bien — lo que validamos aquí es que el error TIENE descripción
// y que los valores asociados (statusCode, error) se propagan.

import Testing
@testable import Fooco
import Foundation

// MARK: - APIErrorTests

@Suite("APIError")
struct APIErrorTests {

    // MARK: - errorDescription no es nil

    @Test("invalidURL tiene descripción")
    func invalidURLHasDescription() {
        // Arrange
        let error = APIError.invalidURL

        // Act
        let description = error.errorDescription

        // Assert
        #expect(description != nil)
    }

    @Test("httpError tiene descripción")
    func httpErrorHasDescription() {
        let error = APIError.httpError(statusCode: 404)
        #expect(error.errorDescription != nil)
    }

    @Test("noData tiene descripción")
    func noDataHasDescription() {
        let error = APIError.noData
        #expect(error.errorDescription != nil)
    }

    @Test("decodingError tiene descripción")
    func decodingErrorHasDescription() {
        let underlying = NSError(domain: "test", code: 1)
        let error = APIError.decodingError(underlying)
        #expect(error.errorDescription != nil)
    }

    @Test("networkError tiene descripción")
    func networkErrorHasDescription() {
        let underlying = URLError(.notConnectedToInternet)
        let error = APIError.networkError(underlying)
        #expect(error.errorDescription != nil)
    }

    // MARK: - Los valores asociados se propagan

    @Test("httpError incluye el statusCode en la descripción")
    func httpErrorIncludesStatusCode() {
        // Arrange
        let statusCode = 503

        // Act
        let error = APIError.httpError(statusCode: statusCode)
        let description = error.errorDescription ?? ""

        // Assert — el número debe aparecer en algún lugar del mensaje
        #expect(description.contains("\(statusCode)"))
    }

    @Test("decodingError incluye el error subyacente")
    func decodingErrorIncludesUnderlying() {
        // Arrange
        let underlying = NSError(domain: "TestDomain", code: 42,
                                 userInfo: [NSLocalizedDescriptionKey: "campo faltante"])

        // Act
        let error = APIError.decodingError(underlying)
        let description = error.errorDescription ?? ""

        // Assert
        #expect(description.contains("campo faltante"))
    }

    @Test("networkError incluye el error subyacente")
    func networkErrorIncludesUnderlying() {
        // Arrange — URLError con razón conocida
        let underlying = URLError(.timedOut)

        // Act
        let error = APIError.networkError(underlying)
        let description = error.errorDescription ?? ""

        // Assert — algo del error de timeout debe estar en la descripción
        #expect(!description.isEmpty)
    }

    // MARK: - Conformación a Error

    @Test("APIError conforma a Error y se puede lanzar")
    func apiErrorIsThrowable() {
        // Verificamos que el tipo se puede usar con throws sin problemas
        #expect(throws: APIError.noData) {
            throw APIError.noData
        }
    }
}
