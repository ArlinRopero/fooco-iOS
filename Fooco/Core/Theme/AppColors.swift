// MARK: - AppColors.swift
//
// Paleta de colores de Fooco.
//
// Dirección de diseño: "Mercado cálido" (Warm Market)
// ─────────────────────────────────────────────────────
// Inspiración: los colores de los mercados latinoamericanos —
// frutas tropicales, especias, terracota, vegetación.
// Opuesto a lo clínico/frío de apps médicas.
// Cercano a lo casero, a la cocina, a la comida real.
//
// Paleta:
//   Primario:    Naranja cálido    #E8672A  — energía, apetito, acción
//   Secundario:  Verde aguacate    #4A7C59  — nutrición, salud natural
//   Acento:      Amarillo mango    #F5A623  — destacados, logros, badges
//   Error:       Rojo tomate       #D94F3D  — errores, alertas
//   Fondo:       Crema suave       #FBF7F2  — calidez, no blanco clínico
//   Texto:       Espresso          #1E1410  — legible, cálido (no negro puro)
//
// ¿Por qué Color(hex:) y no Asset Catalog?
// Los tokens como Color(hex:) son más fáciles de leer en código,
// no requieren saltar al Asset Catalog, y con dark mode manejado
// explícitamente aquí tenemos control total.
//
// Uso:
//   .foregroundStyle(AppColors.primary)
//   .background(AppColors.surface)

import SwiftUI

// MARK: - AppColors

enum AppColors {

    // MARK: - Brand

    /// Naranja cálido — color primario de la app.
    /// Usado en botones principales, tabs activos, íconos de acción.
    static let primary = Color(light: "#E8672A", dark: "#FF8A50")

    /// Verde aguacate — color secundario.
    /// Usado en confirmaciones, tags de nutrición, acciones secundarias.
    static let secondary = Color(light: "#4A7C59", dark: "#6FA882")

    /// Amarillo mango — acento y celebración.
    /// Usado en badges, logros, notificaciones positivas, estrellas.
    static let accent = Color(light: "#F5A623", dark: "#FFB84D")

    // MARK: - Semánticos

    /// Verde éxito — confirmaciones, objetivos cumplidos.
    static let success = Color(light: "#2D8A4E", dark: "#4CAF72")

    /// Rojo error — errores, alertas, alertas de exceso calórico.
    static let error = Color(light: "#D94F3D", dark: "#FF6B5B")

    /// Amarillo advertencia — alertas no críticas, límites cercanos.
    static let warning = Color(light: "#E09B2D", dark: "#FFB347")

    // MARK: - Fondos

    /// Fondo principal de la app — crema suave en light, carbón en dark.
    static let background = Color(light: "#FBF7F2", dark: "#141210")

    /// Fondo de cards y contenedores elevados.
    static let surface = Color(light: "#FFFFFF", dark: "#1E1A17")

    /// Fondo de cards ligeramente elevadas sobre surface.
    static let surfaceElevated = Color(light: "#F5EFE8", dark: "#2A2420")

    /// Fondo de inputs, campos de texto.
    static let inputBackground = Color(light: "#EFE8DF", dark: "#2E2620")

    // MARK: - Texto

    /// Texto principal — espresso cálido (no negro puro).
    static let textPrimary = Color(light: "#1E1410", dark: "#F5EDE4")

    /// Texto secundario — para metadatos, descripciones, placeholders.
    static let textSecondary = Color(light: "#6B5A4E", dark: "#A8968A")

    /// Texto deshabilitado.
    static let textDisabled = Color(light: "#B8A89C", dark: "#5C4F47")

    /// Texto sobre fondos de color (botones, badges).
    static let textOnColor = Color(light: "#FFFFFF", dark: "#FFFFFF")

    // MARK: - Bordes y Separadores

    /// Borde estándar de cards y campos.
    static let border = Color(light: "#E2D5C8", dark: "#3A302A")

    /// Separador sutil entre elementos de lista.
    static let separator = Color(light: "#EDE4DA", dark: "#2E2520")

    // MARK: - Macronutrientes
    //
    // Colores específicos para representar cada macronutriente.
    // Usados en gráficas, badges y detalles nutricionales.

    /// Proteína — azul profundo (asociación: músculo, fuerza).
    static let macroProtein = Color(light: "#3B7DC8", dark: "#5B9DE8")

    /// Carbohidratos — naranja suave (asociación: energía, granos).
    static let macroCarbs = Color(light: "#E8A040", dark: "#FFB84D")

    /// Grasa — morado cálido (asociación: aceites, nueces).
    static let macroFat = Color(light: "#9B6BB5", dark: "#C08FD9")

    /// Fibra — verde musgo (asociación: vegetales, plantas).
    static let macroFiber = Color(light: "#5A9E6F", dark: "#7EC491")

    // MARK: - Progress / Caloric Ring
    //
    // Colores del anillo de progreso calórico diario.

    /// Por debajo del 70% de la meta — todo bien.
    static let progressNormal = Color(light: "#4A7C59", dark: "#6FA882")

    /// Entre 70% y 90% de la meta — ojo.
    static let progressWarning = Color(light: "#E09B2D", dark: "#FFB347")

    /// Por encima del 90% de la meta — límite alcanzado.
    static let progressDanger = Color(light: "#D94F3D", dark: "#FF6B5B")

    /// Fondo del anillo (parte no completada).
    static let progressTrack = Color(light: "#EDE4DA", dark: "#2E2520")
}

// MARK: - Color(light:dark:) helper
//
// Extensión para crear colores adaptativos light/dark desde hex strings.
// Evita tener que crear un Asset Catalog entry por cada color.

private extension Color {

    /// Crea un Color que cambia automáticamente entre light y dark mode.
    /// - Parameters:
    ///   - light: Hex string para light mode. Ej: "#E8672A"
    ///   - dark: Hex string para dark mode. Ej: "#FF8A50"
    init(light lightHex: String, dark darkHex: String) {
        self.init(uiColor: UIColor(
            light: UIColor(hex: lightHex),
            dark:  UIColor(hex: darkHex)
        ))
    }
}

// MARK: - UIColor(hex:) helper

private extension UIColor {

    /// Crea un UIColor desde un string hexadecimal (con o sin #).
    /// Soporta formatos: "#RGB", "#RRGGBB", "#RRGGBBAA"
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let length = hexSanitized.count
        let r, g, b, a: CGFloat

        switch length {
        case 6:
            r = CGFloat((rgb >> 16) & 0xFF) / 255
            g = CGFloat((rgb >> 8)  & 0xFF) / 255
            b = CGFloat(rgb         & 0xFF) / 255
            a = 1.0
        case 8:
            r = CGFloat((rgb >> 24) & 0xFF) / 255
            g = CGFloat((rgb >> 16) & 0xFF) / 255
            b = CGFloat((rgb >> 8)  & 0xFF) / 255
            a = CGFloat(rgb         & 0xFF) / 255
        default:
            // Fallback a un gris si el hex es inválido
            r = 0.5; g = 0.5; b = 0.5; a = 1.0
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }

    /// Crea un UIColor dinámico que alterna entre light y dark.
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        }
    }
}
