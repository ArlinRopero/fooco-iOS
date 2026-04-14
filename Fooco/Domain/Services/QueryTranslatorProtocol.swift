// MARK: - QueryTranslatorProtocol.swift
//
// Contrato para traducir la query del usuario al inglés antes de buscar en USDA.
//
// ¿Por qué está en Domain y no en Data?
// Domain define QUÉ necesita la app: "traduce este texto a inglés".
// No le importa SI usa Apple Translation, Google o un diccionario local.
// Data/Presentation implementan el CÓMO.
//
// Esto permite cambiar la implementación sin tocar el UseCase o el ViewModel.

import Foundation

protocol QueryTranslatorProtocol: Sendable {

    /// Traduce una query al inglés para buscar en la API de USDA.
    ///
    /// - Parameter query: Texto en cualquier idioma. Ej: "pollo asado"
    /// - Returns: Traducción al inglés. Ej: "roasted chicken"
    ///            Si la traducción falla, devuelve la query original sin crash.
    func translateToEnglish(_ query: String) async -> String
}
