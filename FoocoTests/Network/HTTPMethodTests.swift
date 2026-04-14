// MARK: - HTTPMethodTests.swift
//
// ¿Qué probamos aquí?
// Que los rawValues de HTTPMethod coinciden exactamente con los
// strings que el protocolo HTTP espera (RFC 7231 — mayúsculas).
//
// Si alguien cambia accidentalmente .get = "get" en lugar de "GET",
// URLSession enviará el método en minúsculas y muchos servidores
// lo rechazarán. Este test lo atrapa.

import Testing
@testable import Fooco

@Suite("HTTPMethod")
struct HTTPMethodTests {

    @Test("GET tiene rawValue correcto")
    func getHasCorrectRawValue() {
        #expect(HTTPMethod.get.rawValue == "GET")
    }

    @Test("POST tiene rawValue correcto")
    func postHasCorrectRawValue() {
        #expect(HTTPMethod.post.rawValue == "POST")
    }

    @Test("PUT tiene rawValue correcto")
    func putHasCorrectRawValue() {
        #expect(HTTPMethod.put.rawValue == "PUT")
    }

    @Test("PATCH tiene rawValue correcto")
    func patchHasCorrectRawValue() {
        #expect(HTTPMethod.patch.rawValue == "PATCH")
    }

    @Test("DELETE tiene rawValue correcto")
    func deleteHasCorrectRawValue() {
        #expect(HTTPMethod.delete.rawValue == "DELETE")
    }

    @Test("Todos los métodos están en mayúsculas", arguments: HTTPMethod.allCases)
    func allMethodsAreUppercase(method: HTTPMethod) {
        // El rawValue debe ser idéntico a su versión en mayúsculas
        #expect(method.rawValue == method.rawValue.uppercased())
    }
}

// CaseIterable está declarado en HTTPMethod.swift.
// Swift sintetiza allCases automáticamente — no se necesita código aquí.
