// MARK: - PassthroughFoodNameTranslator.swift
//
// Implementación nula de FoodNameTranslatorProtocol.
//
// Úsala cuando:
//   - El dispositivo ya está en inglés (no hay nada que traducir)
//   - En tests (para no depender del framework de UI)
//   - Como default en ViewModels que no necesitan traducción

import Foundation

// MARK: - PassthroughFoodNameTranslator

/// Devuelve los nombres sin modificar.
struct PassthroughFoodNameTranslator: FoodNameTranslatorProtocol {

    func translateNames(_ names: [String]) async -> [String] {
        names
    }
}
