// MARK: - AppleQueryTranslator.swift
//
// Implementación de QueryTranslatorProtocol usando Apple Translation framework.
//
// ¿Por qué en Presentation y no en Data?
// Porque TranslationSession viene del framework de UI de Apple — vive en
// la capa de presentación. La View lo crea via .translationTask y lo inyecta
// aquí. No tiene sentido poner esto en Data donde no hay SwiftUI.
//
// ¿Por qué NO almacenamos la TranslationSession?
// Apple invalida la sesión cuando la View a la que está asociada desaparece
// (ej: al navegar al detalle y volver). Usar una sesión inválida causa un
// fatalError: "Attempted to use TranslationSession after the view disappeared."
//
// Solución — patrón "invalidate + continuation":
//   1. translateToEnglish() guarda la query pendiente y llama a configuration.invalidate()
//   2. Eso le dice a SwiftUI: "vuelve a ejecutar .translationTask con sesión fresca"
//   3. .translationTask llama a performTranslation(using:) con la nueva sesión
//   4. performTranslation traduce y reanuda la continuation
//   5. translateToEnglish() retorna el resultado
//
// Así NUNCA guardamos la sesión — siempre usamos la que SwiftUI nos entrega
// en el momento en que la View está visible y la sesión es válida.
//
// ¿Por qué @Observable?
// Para que SwiftUI detecte el cambio en `configuration` (cuando se invalida)
// y re-dispare .translationTask automáticamente.

import Translation
import Foundation
import Observation

// MARK: - AppleQueryTranslator

/// Traduce queries usando Apple Translation (iOS 17+).
///
/// El flujo de traducción es asíncrono y coordinado con la View:
/// `translateToEnglish` suspende hasta que `.translationTask` entrega
/// una sesión válida y ejecuta la traducción.
@Observable
@MainActor
final class AppleQueryTranslator: QueryTranslatorProtocol {

    // MARK: - Configuración

    /// Configuración para `.translationTask` en la View.
    ///
    /// `nil` cuando el dispositivo ya está en inglés.
    /// Se invalida cada vez que queremos traducir, forzando a SwiftUI
    /// a llamar a `.translationTask` con una sesión nueva y válida.
    var configuration: TranslationSession.Configuration?

    // MARK: - Estado interno

    /// Query que está esperando ser traducida.
    private var pendingQuery: String?

    /// Continuation que suspende `translateToEnglish` hasta tener el resultado.
    private var pendingContinuation: CheckedContinuation<String, Never>?

    // MARK: - Init

    init() {
        let deviceLanguage = Locale.preferredLanguages.first ?? "en"
        let languageCode = Locale(identifier: deviceLanguage).language.languageCode?.identifier ?? "en"

        guard languageCode != "en" else {
            // Dispositivo en inglés → configuración nil → .translationTask(nil) no hace nada
            configuration = nil
            return
        }

        configuration = TranslationSession.Configuration(
            source: Locale.Language(identifier: languageCode),
            target: Locale.Language(identifier: "en")
        )
    }

    // MARK: - QueryTranslatorProtocol

    /// Traduce la query al inglés.
    ///
    /// Suspende hasta que `.translationTask` entregue una sesión válida
    /// y complete la traducción. Garantiza que NUNCA lanza — si algo falla
    /// devuelve la query original para que la búsqueda siempre intente ejecutarse.
    func translateToEnglish(_ query: String) async -> String {
        guard configuration != nil else {
            #if DEBUG
            print("🔤 QueryTranslator: dispositivo en inglés, sin traducción")
            #endif
            return query
        }

        #if DEBUG
        print("🔤 QueryTranslator: traduciendo '\(query)' → EN")
        #endif

        pendingQuery = query
        configuration?.invalidate()

        let result = await withCheckedContinuation { continuation in
            pendingContinuation = continuation
        }

        #if DEBUG
        print("🔤 QueryTranslator: '\(query)' → '\(result)'")
        #endif

        return result
    }

    // MARK: - Interfaz con la View

    /// Ejecuta la traducción pendiente usando la sesión provista por `.translationTask`.
    ///
    /// Llamado desde el closure de `.translationTask` en la View.
    /// La sesión es siempre válida aquí — Apple garantiza que la View está visible.
    func performTranslation(using session: TranslationSession) async {
        // Si no hay query pendiente (ej: primera llamada al montar la View), ignorar.
        guard let query = pendingQuery else { return }

        // Capturamos y limpiamos el estado antes de la operación async
        // para evitar condiciones de carrera si se llama de nuevo.
        let continuation = pendingContinuation
        pendingQuery = nil
        pendingContinuation = nil

        do {
            let response = try await session.translate(query)
            let translated = response.targetText
            continuation?.resume(returning: translated.isEmpty ? query : translated)
        } catch {
            // Fallo silencioso — la búsqueda continúa con el original
            continuation?.resume(returning: query)
        }
    }
}
