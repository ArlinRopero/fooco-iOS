// MARK: - FoocoApp.swift
//
// Punto de entrada de la app.
//
// ¿Por qué AppDelegate + @UIApplicationDelegateAdaptor?
// Firebase (especialmente Crashlytics) necesita estar listo antes de que
// SwiftUI arranque cualquier vista. El ciclo correcto garantizado por
// Apple es application(_:didFinishLaunchingWithOptions:) en UIApplicationDelegate.
// Llamar FirebaseApp.configure() en el init() de un SwiftUI App puede
// ocurrir después de que el SDK intente usarse, causando crashes.
//
// Flujo de inicialización:
//   1. AppDelegate.didFinishLaunching → FirebaseApp.configure()
//   2. FoocoApp.init()               → FirebaseManager() (Firestore, repos, Analytics)
//   3. body                          → MainTabView recibe los repositorios

import SwiftUI
import FirebaseCore

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        AnalyticsManager.shared = FirebaseAnalyticsService()
        return true
    }
}

// MARK: - FoocoApp

@main
struct FoocoApp: App {

    // MARK: - AppDelegate (requerido por Firebase)

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // MARK: - Firebase: repositorios y servicios

    private let firebase: FirebaseManager

    // MARK: - Init

    init() {
        // FirebaseApp.configure() ya fue llamado en AppDelegate.
        // FirebaseManager solo configura Firestore y crea repositorios.
        self.firebase = FirebaseManager()
    }

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            MainTabView(
                logRepository:     firebase.foodLogRepository,
                profileRepository: firebase.profileRepository
            )
            .environment(\.analyticsService, firebase.analyticsService)
        }
    }
}

// MARK: - EnvironmentKey para AnalyticsService

private struct AnalyticsServiceKey: EnvironmentKey {
    static let defaultValue: any AnalyticsServiceProtocol = NoOpAnalyticsService()
}

extension EnvironmentValues {
    var analyticsService: any AnalyticsServiceProtocol {
        get { self[AnalyticsServiceKey.self] }
        set { self[AnalyticsServiceKey.self] = newValue }
    }
}

