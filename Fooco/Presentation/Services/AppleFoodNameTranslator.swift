// MARK: - AppleFoodNameTranslator.swift
//
// Traduce nombres de alimentos (EN → idioma del dispositivo) en batch
// usando Apple Translation framework.
//
// ¿Por qué el mismo patrón invalidate + continuation que AppleQueryTranslator?
// Apple invalida la TranslationSession cuando la View desaparece.
// Almacenar la sesión causa un fatalError al usarla después de navegar.
// Solución: no almacenar — pedir sesión fresca con invalidate() cada vez.
//
// Flujo por búsqueda:
//   1. SearchViewModel llama translateNames(["Avocado, raw", "Chicken..."])
//   2. translateNames guarda los nombres y llama configuration.invalidate()
//   3. SwiftUI detecta el cambio (@Observable) y re-ejecuta .translationTask
//   4. .translationTask llama performTranslation(using:) con sesión válida
//   5. performTranslation traduce en batch y reanuda la continuation
//   6. translateNames retorna ["Aguacate crudo", "Pollo..."]
//
// ¿Por qué source explícito "en"?
// Sin source, Apple muestra un prompt "¿en qué idioma está el texto?"
// Los nombres de USDA siempre están en inglés — podemos declararlo explícitamente.

import Translation
import Foundation
import Observation

// MARK: - AppleFoodNameTranslator

/// Traduce nombres de alimentos de inglés al idioma del dispositivo.
///
/// Usa traducción en batch: todos los nombres de una búsqueda en un solo request.
@Observable
@MainActor
final class AppleFoodNameTranslator: FoodNameTranslatorProtocol {

    // MARK: - Configuración

    /// Configuración para `.translationTask` en la View.
    ///
    /// `nil` cuando el dispositivo ya está en inglés — no hay nada que traducir.
    /// Se invalida con cada llamada a `translateNames` para obtener sesión fresca.
    var configuration: TranslationSession.Configuration?

    // MARK: - Estado interno

    private var pendingNames: [String]?
    private var pendingContinuation: CheckedContinuation<[String], Never>?

    // MARK: - Init

    init() {
        let deviceLanguage = Locale.preferredLanguages.first ?? "en"
        let languageCode = Locale(identifier: deviceLanguage).language.languageCode?.identifier ?? "en"

        guard languageCode != "en" else {
            configuration = nil
            return
        }

        // source: "en" explícito → sin prompt al usuario
        // target: idioma del dispositivo → ej. "es", "pt"
        configuration = TranslationSession.Configuration(
            source: Locale.Language(identifier: "en"),
            target: Locale.Language(identifier: languageCode)
        )
    }

    // MARK: - FoodNameTranslatorProtocol

    func translateNames(_ names: [String]) async -> [String] {
        guard configuration != nil, !names.isEmpty else {
            #if DEBUG
            print("🏷️  NameTranslator: dispositivo en inglés, sin traducción (\(names.count) nombres)")
            #endif
            return names
        }

        #if DEBUG
        print("🏷️  NameTranslator: traduciendo \(names.count) nombres EN → dispositivo")
        #endif

        pendingNames = names
        configuration?.invalidate()

        let results = await withCheckedContinuation { continuation in
            pendingContinuation = continuation
        }

        #if DEBUG
        let pairs = zip(names.prefix(3), results.prefix(3))
            .map { "'\($0)' → '\($1)'" }
            .joined(separator: ", ")
        let suffix = names.count > 3 ? " (+ \(names.count - 3) más)" : ""
        print("🏷️  NameTranslator: \(pairs)\(suffix)")
        #endif

        return results
    }

    // MARK: - Interfaz con la View

    /// Ejecuta la traducción en batch con la sesión provista por `.translationTask`.
    ///
    /// Llamado desde el closure de `.translationTask` en la View.
    func performTranslation(using session: TranslationSession) async {
        guard let names = pendingNames else { return }

        let continuation = pendingContinuation
        pendingNames = nil
        pendingContinuation = nil

        do {
            // Traducción concurrente: un Task por nombre, preservamos el orden
            // con índices. withTaskGroup garantiza que todos terminen antes
            // de continuar, y es compatible con iOS 17.0+.
            var resultMap: [Int: String] = [:]
            try await withThrowingTaskGroup(of: (Int, String).self) { group in
                for (index, name) in names.enumerated() {
                    group.addTask {
                        let response = try await session.translate(name)
                        let translated = response.targetText.isEmpty ? name : response.targetText
                        return (index, translated)
                    }
                }
                for try await (index, translated) in group {
                    resultMap[index] = translated
                }
            }

            let translated = names.indices.map { resultMap[$0] ?? names[$0] }
            continuation?.resume(returning: translated)
        } catch {
            // Fallo silencioso — devolvemos los nombres originales en inglés
            continuation?.resume(returning: names)
        }
    }
}
