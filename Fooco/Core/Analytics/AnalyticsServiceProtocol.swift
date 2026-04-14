// MARK: - AnalyticsServiceProtocol.swift
//
// Contrato para el servicio de Analytics.
// La app solo depende de este protocolo — no de Firebase directamente.
// Esto permite intercambiar el proveedor (Firebase → Mixpanel, etc.)
// sin tocar ninguna pantalla, y facilita los tests (MockAnalyticsService).

import Foundation

// MARK: - AnalyticsServiceProtocol

protocol AnalyticsServiceProtocol: Sendable {

    /// Registra un evento con sus parámetros.
    func log(_ event: AnalyticsEvent)

    /// Asocia el ID de usuario de Firebase Auth para atribuir eventos.
    /// Llamar al hacer login; pasar `nil` al hacer logout.
    func setUserID(_ uid: String?)

    /// Establece una propiedad de usuario persistente
    /// (p.ej. "subscription_tier": "premium").
    func setUserProperty(_ value: String?, forName name: String)
}
