// MARK: - FoodNameTranslatorProtocol.swift
//
// Contrato para traducir nombres de alimentos al idioma del dispositivo.
//
// ¿Por qué está separado de QueryTranslatorProtocol?
// Son flujos opuestos:
//   QueryTranslator:    español → inglés  (query del usuario → API USDA)
//   FoodNameTranslator: inglés → español  (resultados de API → UI)
//
// ¿Por qué batch ([String] → [String]) y no uno a uno?
// La búsqueda devuelve hasta 25 resultados. Llamar a la API de
// traducción 25 veces sería 25 roundtrips. Apple Translation soporta
// traducción en batch — un solo request para todos los nombres.
//
// Contrato de tamaño:
//   El array devuelto SIEMPRE tiene el mismo tamaño que el de entrada.
//   Si un nombre no se pudo traducir, se devuelve el original.
//   Así el caller puede hacer zip(foods, translatedNames) sin riesgos.

import Foundation

// MARK: - FoodNameTranslatorProtocol

/// Traduce nombres de alimentos en inglés al idioma del dispositivo.
///
/// Implementaciones:
/// - `PassthroughFoodNameTranslator` — para inglés y tests (no hace nada)
/// - `AppleFoodNameTranslator` — traducción on-device con Apple Translation
protocol FoodNameTranslatorProtocol: Sendable {

    /// Traduce un array de nombres de alimentos en inglés.
    ///
    /// - Parameter names: Nombres en inglés (vienen de la API USDA).
    /// - Returns: Nombres en el idioma del dispositivo.
    ///   Mismo tamaño que `names`. Nunca lanza — usa original si falla.
    func translateNames(_ names: [String]) async -> [String]
}
