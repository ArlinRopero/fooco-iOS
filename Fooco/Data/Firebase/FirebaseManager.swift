// MARK: - FirebaseManager.swift
//
// Punto único de inicialización de Firebase y fábrica de dependencias.
//
// ¿Singleton o DI?
// Este archivo usa DI: FirebaseManager es creado UNA vez en FoocoApp
// e inyectado hacia abajo. No usamos App.firebaseApp() directamente
// en las vistas — todo pasa por los repositorios.
//
// ¿Por qué no static let shared?
// Los singletons esconden dependencias y dificultan los tests.
// Un objeto creado en el Composition Root (FoocoApp) e inyectado
// es más predecible y testeable.
//
// Servicios inicializados:
//   • FirebaseApp      — core SDK
//   • Firestore        — base de datos
//   • FirebaseAuth     — autenticación (preparado para Auth)
//   • FirebaseCrashlytics — reporte de errores
//   • FirebaseAnalytics   — eventos de uso
//
// NOTA: Requiere GoogleService-Info.plist en el bundle del target.
//       Descárgalo desde Firebase Console → Configuración del proyecto.

import FirebaseFirestore
import FirebaseCrashlytics
import FirebaseAnalytics
import Foundation

// MARK: - FirebaseManager

final class FirebaseManager {

    // MARK: - Repositorios expuestos

    let foodLogRepository:  any FoodLogRepositoryProtocol
    let profileRepository:  any UserProfileRepositoryProtocol
    let recipeRepository:   any RecipeRepositoryProtocol

    // MARK: - Servicios

    let analyticsService: any AnalyticsServiceProtocol

    // MARK: - Init

    init() {
        // FirebaseApp.configure() ya fue llamado en AppDelegate.
        // Aquí configuramos Firestore y construimos los repositorios.

        let db = Firestore.firestore()

        // 1. Emulador local (solo en desarrollo con AppEnvironment.useEmulator = true)
        if AppEnvironment.useEmulator && AppEnvironment.current.isDevelopment {
            let settings = FirestoreSettings()
            settings.host = "\(AppEnvironment.emulatorHost):\(AppEnvironment.emulatorFirestorePort)"
            settings.cacheSettings = MemoryCacheSettings()
            settings.isSSLEnabled = false
            db.settings = settings
            print("🔧 Firestore conectado al emulador local (\(settings.host))")
        } else {
            // 2. Producción/Dev remoto: caché offline de 100 MB
            let settings = FirestoreSettings()
            settings.cacheSettings = PersistentCacheSettings(sizeBytes: NSNumber(value: 100 * 1024 * 1024))
            db.settings = settings
        }

        // 3. Crear repositorios con la misma instancia de Firestore
        self.foodLogRepository = FirestoreFoodLogRepository(db: db)
        self.profileRepository = FirestoreUserProfileRepository(db: db)
        self.recipeRepository  = FirestoreRecipeRepository(db: db)

        // 4. Analytics + Crashlytics
        self.analyticsService = FirebaseAnalyticsService()

        if AppEnvironment.current.isDevelopment {
            print("🟡 Fooco corriendo en DEVELOPMENT → Firebase proyecto: Fooco-Dev")
        }
    }
}

// MARK: - FirebaseAnalyticsService

final class FirebaseAnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {

    func log(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)
    }

    func setUserID(_ uid: String?) {
        Analytics.setUserID(uid)
        if let uid {
            Crashlytics.crashlytics().setUserID(uid)
        }
    }

    func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
}

// MARK: - CrashlyticsHelper
//
// Extensión para registrar errores no fatales desde cualquier capa.
// Uso: CrashlyticsHelper.record(error, context: "FirestoreFoodLogRepository.logFood")

enum CrashlyticsHelper {

    /// Registra un error no fatal con contexto adicional.
    static func record(_ error: Error, context: String, extra: [String: Any] = [:]) {
        var keys: [String: Any] = ["context": context]
        keys.merge(extra) { _, new in new }

        let crashlytics = Crashlytics.crashlytics()
        for (key, value) in keys {
            crashlytics.setCustomValue(value, forKey: key)
        }
        crashlytics.record(error: error)
    }
}
