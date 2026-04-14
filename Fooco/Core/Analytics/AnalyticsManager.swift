// MARK: - AnalyticsManager.swift
//
// Punto de acceso global a Analytics.
//
// ¿Por qué no Singleton puro?
// Un `static let shared = FirebaseAnalyticsService()` acopla directamente
// a Firebase en todo el código. En cambio, `AnalyticsManager.shared` es
// un protocolo configurable → los tests pueden reemplazarlo con un mock.
//
// Configuración (en AppDelegate, después de FirebaseApp.configure()):
//   AnalyticsManager.shared = FirebaseAnalyticsService()
//
// Uso desde cualquier ViewModel o capa de datos:
//   AnalyticsManager.log(.foodLogged(...))
//   AnalyticsManager.log(.saberMasViewed(foodId: 123, foodName: "Arroz"))

import Foundation

// MARK: - AnalyticsManager

enum AnalyticsManager {

    // MARK: - Shared instance (reemplazable en tests)

    /// Implementación activa. Por defecto es NoOp hasta que AppDelegate
    /// la reemplaza con FirebaseAnalyticsService.
    static var shared: any AnalyticsServiceProtocol = NoOpAnalyticsService()

    // MARK: - API pública

    /// Registra un evento de Analytics.
    static func log(_ event: AnalyticsEvent) {
        shared.log(event)
    }

    /// Asocia el UID del usuario autenticado a los eventos futuros.
    /// Llamar en login; pasar `nil` en logout.
    static func setUserID(_ uid: String?) {
        shared.setUserID(uid)
    }

    /// Establece una propiedad de usuario persistente.
    /// Ejemplo: `setUserProperty("premium", forName: "subscription_tier")`
    static func setUserProperty(_ value: String?, forName name: String) {
        shared.setUserProperty(value, forName: name)
    }
}

// MARK: - NoOpAnalyticsService

/// Implementación vacía para Previews, Tests y el estado inicial antes
/// de que Firebase esté configurado.
struct NoOpAnalyticsService: AnalyticsServiceProtocol {
    func log(_ event: AnalyticsEvent) {}
    func setUserID(_ uid: String?) {}
    func setUserProperty(_ value: String?, forName name: String) {}
}
