// MARK: - MockURLProtocol.swift
//
// ¿Qué hace este archivo?
// Intercepta todas las peticiones de URLSession durante los tests
// y devuelve respuestas predefinidas sin tocar la red real.
//
// ¿Por qué URLProtocol?
// URLSession tiene un sistema de "protocolos" que procesa las peticiones.
// Por defecto usa HTTP/HTTPS. Podemos registrar uno propio que intercepte
// todo y devuelva lo que queramos — ideal para tests.
//
// Cómo se usa:
//   1. Registrar antes del test:
//      MockURLProtocol.requestHandler = { request in
//          return (HTTPURLResponse(..., statusCode: 200, ...), data)
//      }
//   2. Crear una URLSession configurada con este protocolo:
//      let config = URLSessionConfiguration.ephemeral
//      config.protocolClasses = [MockURLProtocol.self]
//      let session = URLSession(configuration: config)
//   3. Pasarla al NetworkManager en el init.

import Foundation

final class MockURLProtocol: URLProtocol {

    // MARK: - Handler

    /// Closure que los tests configuran para definir qué devolver.
    /// Recibe el request real y retorna (respuesta HTTP, datos JSON).
    /// Si lanza, URLSession propaga el error al llamador.
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    // MARK: - URLProtocol overrides

    /// Le dice a URLSession que este protocolo puede manejar cualquier request.
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    /// Retorna el request sin modificarlo.
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    /// Aquí ocurre la magia: en lugar de ir a la red, usamos el handler.
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }

        do {
            let (response, data) = try handler(request)
            // Simula recibir la respuesta HTTP
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            // Simula recibir los datos
            client?.urlProtocol(self, didLoad: data)
            // Indica que la "petición" terminó
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // Nada que cancelar en un mock
    }
}

// MARK: - Helpers para tests

extension MockURLProtocol {

    /// Crea una URLSession configurada para usar este mock.
    /// Usar en el setUp de cada test de NetworkManager.
    static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        // `ephemeral` = sin caché, sin cookies — perfecto para tests aislados
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    /// Construye una HTTPURLResponse con los parámetros más comunes.
    static func makeResponse(statusCode: Int, url: URL = URL(string: "https://test.com")!) -> HTTPURLResponse {
        HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
    }
}
