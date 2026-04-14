// MARK: - Environment.swift
//
// Identifica en qué ambiente está corriendo la app.
//
// Debug   → AppEnvironment.development → Firebase proyecto Fooco-Dev
// Release → AppEnvironment.production  → Firebase proyecto Fooco-Prod
//
// El switch del GoogleService-Info.plist lo hace el build script
// en Xcode (ver Scripts/select_firebase_env.sh).
// Este enum existe para que el código Swift pueda tomar decisiones
// adicionales según el ambiente (logs, banners de dev, emuladores, etc.)

import Foundation

// MARK: - AppEnvironment

enum AppEnvironment {
    case development
    case production

    // MARK: - Ambiente actual (basado en configuración de build)

    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    // MARK: - Propiedades

    var displayName: String {
        switch self {
        case .development: return "Development"
        case .production:  return "Production"
        }
    }

    var isDevelopment: Bool { self == .development }
    var isProduction:  Bool { self == .production  }

    // MARK: - Firestore Local Emulator
    //
    // En desarrollo puedes correr `firebase emulators:start` para
    // trabajar completamente offline sin tocar el proyecto Fooco-Dev.
    // Cambia useEmulator a true cuando quieras trabajar con el emulador.

    static let useEmulator = false

    static let emulatorHost = "127.0.0.1"
    static let emulatorFirestorePort = 8080
    static let emulatorAuthPort      = 9099
}
