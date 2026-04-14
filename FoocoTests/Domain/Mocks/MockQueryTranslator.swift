// MARK: - MockQueryTranslator.swift
//
// Mock de QueryTranslatorProtocol para tests del SearchViewModel.
//
// Permite controlar exactamente qué devuelve la "traducción" sin
// depender de Apple Translation, internet, ni sesiones de UI.
//
// Comportamientos configurables:
//   1. Mapeo fijo: "pollo" → "chicken"  (para verificar que se usa la traducción)
//   2. Passthrough: devuelve el original (comportamiento por default)
//   3. Delay simulado: para testear estados de loading con traducción lenta

import Foundation
@testable import Fooco

final class MockQueryTranslator: QueryTranslatorProtocol, @unchecked Sendable {

    // MARK: - Configuración

    /// Mapeo estático de traducciones. Si la query está aquí, devuelve el valor.
    /// Si no está, devuelve la query original (passthrough).
    var translations: [String: String] = [:]

    /// Si está configurado, se lanza en lugar de traducir.
    /// Útil para simular fallos del framework de traducción.
    /// (No lanza porque el protocolo garantiza que nunca falla — devuelve original)

    // MARK: - Registro (Spy)

    private(set) var callCount = 0
    private(set) var receivedQueries: [String] = []

    // MARK: - QueryTranslatorProtocol

    func translateToEnglish(_ query: String) async -> String {
        callCount += 1
        receivedQueries.append(query)

        // Si hay una traducción configurada para esta query, úsala.
        // Si no, passthrough — igual que el comportamiento real cuando falla.
        return translations[query] ?? query
    }
}
