// MARK: - PassthroughQueryTranslator.swift
//
// Implementación nula de QueryTranslatorProtocol.
// Devuelve la query sin modificar — útil como default antes de que
// AppleQueryTranslator reciba su sesión, y en los tests del ViewModel.

import Foundation

struct PassthroughQueryTranslator: QueryTranslatorProtocol {
    func translateToEnglish(_ query: String) async -> String { query }
}
