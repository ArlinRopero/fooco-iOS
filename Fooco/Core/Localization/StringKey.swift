// MARK: - StringKey.swift
//
// ¿Qué hace este archivo?
// Centraliza todas las claves de localización de la app como constantes
// tipadas. El objetivo es que NUNCA se escriba un string literal suelto
// para acceder al catálogo de textos.
//
// ¿Por qué?
// Si escribimos NSLocalizedString("error.invalid_url", ...) disperso por
// el código, un simple typo ("error.invalid_URl") compila sin problema
// pero falla en tiempo de ejecución mostrando la clave cruda al usuario.
// Con constantes, el compilador atrapa ese error.
//
// Patrón: Namespace con enums vacíos
// Los enums sin casos no se pueden instanciar — son namespaces puros.
// Agrupa las claves por dominio: Error, Search, Detail, Log.
//
// Uso:
//   localized(StringKey.Error.noData)
//   localized(StringKey.Error.httpError, args: 404)

import Foundation

// MARK: - StringKey (namespace raíz)

/// Namespace raíz. Agrupa todas las claves del catálogo por dominio.
enum StringKey {

    // MARK: - Error (red y API)

    /// Claves para los mensajes de error de red (APIError).
    enum Error {

        /// URL inválida generada por el Router.
        static let invalidURL    = "error.invalid_url"

        /// El servidor respondió con un código HTTP no exitoso.
        /// Requiere un argumento Int (%lld) con el código de estado.
        static let httpError     = "error.http_error"

        /// El servidor respondió con cuerpo vacío.
        static let noData        = "error.no_data"

        /// JSONDecoder no pudo mapear la respuesta al modelo.
        /// Requiere un argumento String (%@) con la descripción del error subyacente.
        static let decodingError = "error.decoding_error"

        /// Error genérico de red (sin conexión, timeout, etc.).
        /// Requiere un argumento String (%@) con la descripción del error subyacente.
        static let networkError  = "error.network_error"

        /// El ID del alimento pasado a GetFoodDetailUseCase era <= 0.
        static let foodDetailInvalidID = "error.food_detail.invalid_id"

        /// La query de búsqueda era demasiado corta.
        static let searchQueryTooShort = "error.search.query_too_short"
    }

    // MARK: - Search

    /// Claves para la pantalla de búsqueda (SearchView).
    enum Search {
        static let title            = "search.title"
        static let placeholder      = "search.placeholder"
        static let idleTitle        = "search.idle.title"
        static let idleSubtitle     = "search.idle.subtitle"
        static let suggestionsTitle = "search.suggestions.title"
        static let frequentTitle    = "search.frequent.title"
        static let emptyTitle       = "search.empty.title"
        static let emptySubtitle    = "search.empty.subtitle"
        static let errorTitle       = "search.error.title"
        static let errorRetry       = "search.error.retry"
    }

    // MARK: - Detail

    /// Claves para la pantalla de detalle nutricional (FoodDetailView).
    enum Detail {
        static let caloriesLabel    = "detail.calories.label"
        static let per100g          = "detail.per_100g"
        static let macrosTitle      = "detail.macros.title"
        static let macroProtein     = "detail.macro.protein"
        static let macroCarbs       = "detail.macro.carbs"
        static let macroFat         = "detail.macro.fat"
        static let secondaryTitle   = "detail.secondary.title"
        static let nutrientFiber    = "detail.nutrient.fiber"
        static let nutrientSugar    = "detail.nutrient.sugar"
        static let nutrientSodium   = "detail.nutrient.sodium"
        static let servingNote      = "detail.serving_note"
        static let logSectionTitle  = "detail.log.section_title"
        static let logButton        = "detail.log.button"
        static let logSuccess       = "detail.log.success"
        static let knowMoreButton   = "detail.know_more.button"
        static let knowMoreLoading  = "detail.know_more.loading"
        static let knowMoreTitle    = "detail.know_more.title"
        static let knowMorePortions = "detail.know_more.portions"
        static let knowMoreMinerals = "detail.know_more.minerals"
        static let knowMoreVitamins = "detail.know_more.vitamins"
        static let knowMoreFats     = "detail.know_more.fats"
    }

    // MARK: - Log

    /// Claves para el registro de alimentos consumidos.
    enum Log {
        /// Gramos inválidos (debe ser > 0) al llamar a LogFoodUseCase.
        static let errorInvalidGrams    = "log.error.invalid_grams"

        // LogView
        static let screenTitle          = "log.screen.title"
        static let todayCaloriesLabel   = "log.today.calories.label"
        static let todaySection         = "log.today.section"
        static let todayEmptyTitle      = "log.today.empty.title"
        static let todayEmptySubtitle   = "log.today.empty.subtitle"
        static let weekSection          = "log.week.section"
        static let weekEmpty            = "log.week.empty"
        static let macroProtein         = "log.macro.protein"
        static let macroCarbs           = "log.macro.carbs"
        static let macroFat             = "log.macro.fat"
    }

    // MARK: - Food types

    /// Claves para los tipos de base de datos de alimentos (Food.DataType).
    enum FoodType {
        static let foundation = "food.type.foundation"
        static let srLegacy   = "food.type.sr_legacy"
        static let branded    = "food.type.branded"
        static let unknown    = "food.type.unknown"
    }

    // MARK: - Tabs

    /// Claves para los labels de las tabs (MainTabView).
    enum Tab {
        static let library = "tab.library"
        static let log     = "tab.log"
        static let stats   = "tab.stats"
        static let profile = "tab.profile"
    }

    // MARK: - Profile

    /// Claves para la pantalla de perfil del usuario.
    enum Profile {
        static let screenTitle              = "profile.screen.title"
        static let sectionPersonal          = "profile.section.personal"
        static let nameLabel                = "profile.name.label"
        static let namePlaceholder          = "profile.name.placeholder"
        static let sexLabel                 = "profile.sex.label"
        static let sexMale                  = "profile.sex.male"
        static let sexFemale                = "profile.sex.female"
        static let sexUnspecified           = "profile.sex.unspecified"
        static let birthYearLabel           = "profile.birth_year.label"
        static let birthYearPlaceholder     = "profile.birth_year.placeholder"
        static let weightLabel              = "profile.weight.label"
        static let weightPlaceholder        = "profile.weight.placeholder"
        static let heightLabel              = "profile.height.label"
        static let heightPlaceholder        = "profile.height.placeholder"
        static let sectionActivity          = "profile.section.activity"
        static let activityLabel            = "profile.activity.label"
        static let activitySedentary        = "profile.activity.sedentary"
        static let activityLightlyActive    = "profile.activity.lightly_active"
        static let activityModeratelyActive = "profile.activity.moderately_active"
        static let activityVeryActive       = "profile.activity.very_active"
        static let activityExtraActive      = "profile.activity.extra_active"
        static let sectionGoal              = "profile.section.goal"
        static let caloriesLabel            = "profile.calories.label"
        static let caloriesAutoPlaceholder  = "profile.calories.auto_placeholder"
        static let sectionHealth            = "profile.section.health"
        static let healthSearchPlaceholder  = "profile.health.search.placeholder"
        static let conditionAnemia          = "profile.condition.anemia"
        static let conditionDiabetes2       = "profile.condition.diabetes2"
        static let conditionPregnancy       = "profile.condition.pregnancy"
        static let conditionHypertension    = "profile.condition.hypertension"
        static let conditionOsteoporosis    = "profile.condition.osteoporosis"
        static let conditionHypothyroidism  = "profile.condition.hypothyroidism"
        static let saveButton               = "profile.save.button"
        static let saveSuccess              = "profile.save.success"
        static let emptySubtitle            = "profile.empty.subtitle"
    }

    // MARK: - Profile Menu

    enum ProfileMenu {
        static let sectionInfo          = "profile.menu.section.info"
        static let sectionApp           = "profile.menu.section.app"
        static let personal             = "profile.menu.personal"
        static let health               = "profile.menu.health"
        static let settings             = "profile.menu.settings"
        static let anonymous            = "profile.menu.anonymous"
        static let statusIncomplete     = "profile.menu.status.incomplete"
        static let healthDescription    = "profile.health.description"
        static let healthSelectedTitle  = "profile.health.selected_title"
        static let healthNoResults      = "profile.health.no_results"
    }

    // MARK: - Settings

    enum Settings {
        static let sectionUnits       = "settings.section.units"
        static let sectionAppearance  = "settings.section.appearance"
        static let sectionAbout       = "settings.section.about"
        static let unitsLabel         = "settings.units.label"
        static let unitsMetric        = "settings.units.metric"
        static let unitsImperial      = "settings.units.imperial"
        static let appearanceLabel    = "settings.appearance.label"
        static let appearanceSystem   = "settings.appearance.system"
        static let appearanceLight    = "settings.appearance.light"
        static let appearanceDark     = "settings.appearance.dark"
        static let aboutAppName       = "settings.about.app_name"
        static let aboutVersion       = "settings.about.version"
    }

    // MARK: - General

    /// Claves generales reutilizables.
    enum General {
        static let comingSoon     = "coming.soon"
        static let unitKcal       = "unit.kcal"
        static let errorTitle     = "error.generic.title"
    }
}

// MARK: - Helpers de localización

/// Retorna el string localizado para la clave indicada.
///
/// Wrappea `NSLocalizedString` para reducir verbosidad.
/// Usar cuando el string NO tiene argumentos de formato.
///
/// Ejemplo:
/// ```swift
/// let text = localized(StringKey.Error.noData)
/// ```
func localized(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

/// Retorna el string localizado con sustitución de argumentos de formato.
///
/// Usar cuando el string contiene `%@`, `%lld`, etc.
///
/// Ejemplo:
/// ```swift
/// let text = localized(StringKey.Error.httpError, args: 404)
/// ```
func localized(_ key: String, args: CVarArg...) -> String {
    String(format: NSLocalizedString(key, comment: ""), arguments: args)
}
