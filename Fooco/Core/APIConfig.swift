// MARK: - APIConfig.swift
//
// ¿Qué hace este archivo?
// Lee las credenciales de la app desde Info.plist en tiempo de ejecución.
//
// Flujo:
//   Secrets.xcconfig  →  USDA_API_KEY = tu_key
//       ↓ Xcode inyecta en build time
//   Info.plist  →  USDA_API_KEY = $(USDA_API_KEY)
//       ↓ Swift lee en runtime
//   APIConfig.usdaKey
//       ↓ NetworkManager lo agrega como query param
//   GET /foods/search?query=apple&api_key=tu_key

import Foundation

// MARK: - APIConfig

/// Punto centralizado para credenciales y URLs base de la app.
///
/// `enum` sin casos = namespace puro, no se puede instanciar.
enum APIConfig {

    // MARK: - USDA FoodData Central

    /// URL base de la API de USDA FoodData Central (v1).
    static let usdaBaseURL = "https://api.nal.usda.gov/fdc/v1"

    /// API key leída desde Info.plist.
    ///
    /// Es `@MainActor` porque `Bundle.main.infoDictionary` está aislado
    /// al hilo principal en Swift 6. Marcarlo explícitamente evita que
    /// Swift infiera todo el tipo `APIConfig` como @MainActor, lo que
    /// causaría que `usdaBaseURL` (una constante simple) también lo fuera.
    ///
    /// La USDA la espera como query param: ?api_key=TU_KEY
    /// El NetworkManager la añade automáticamente a cada request.
    @MainActor
    static var usdaKey: String {
        guard let key = Bundle.main.infoDictionary?["USDA_API_KEY"] as? String,
              !key.isEmpty,
              key != "PON_TU_KEY_AQUI" else {
            fatalError(
                """
                ⚠️  API key de USDA no configurada.
                1. Abre Fooco/Config/Secrets.xcconfig
                2. Reemplaza PON_TU_KEY_AQUI con tu key real
                3. En Xcode: Project → Info → Configurations
                   asigna Secrets.xcconfig a Debug y Release
                4. En Info.plist agrega:
                   USDA_API_KEY = $(USDA_API_KEY)
                """
            )
        }
        return key
    }
}
