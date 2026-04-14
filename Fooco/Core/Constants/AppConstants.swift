// MARK: - AppConstants.swift
//
// Constantes globales de diseño para Fooco.
//
// ¿Por qué este archivo?
// Evita "magic numbers" dispersos por toda la app.
// Un solo lugar para cambiar el espaciado y se actualiza todo.
//
// ¿Por qué múltiplos de 4/8?
// Es el sistema de espaciado estándar en diseño de apps (Material, HIG de Apple).
// Múltiplos de 8 crean ritmo visual consistente.
// Múltiplos de 4 para ajustes más finos.
//
// Ejemplo de uso:
//   .padding(AppConstants.Spacing.md)       // 16pt
//   .cornerRadius(AppConstants.Radius.card) // 16pt
//   .font(.system(size: AppConstants.FontSize.body)) // 16pt

import Foundation

// MARK: - AppConstants

enum AppConstants {

    // MARK: - Spacing
    //
    // Sistema de espaciado basado en múltiplos de 4.
    // xs → xxl cubre el 95% de los casos de uso.

    enum Spacing {
        /// 4pt — separación mínima entre elementos muy cercanos
        static let xs: CGFloat = 4
        /// 8pt — espaciado interno compacto (chips, badges)
        static let sm: CGFloat = 8
        /// 12pt — padding interno de componentes medianos
        static let smMd: CGFloat = 12
        /// 16pt — espaciado estándar (padding de cards, entre items de lista)
        static let md: CGFloat = 16
        /// 20pt — espaciado medio-grande
        static let mdLg: CGFloat = 20
        /// 24pt — espaciado entre secciones dentro de una pantalla
        static let lg: CGFloat = 24
        /// 32pt — separación entre bloques principales
        static let xl: CGFloat = 32
        /// 40pt — márgenes de pantalla en layouts espaciosos
        static let xxl: CGFloat = 40
        /// 48pt — separación entre secciones mayores
        static let xxxl: CGFloat = 48

        /// Margen horizontal estándar de la pantalla
        static let screenHorizontal: CGFloat = 16
        /// Margen vertical estándar de la pantalla
        static let screenVertical: CGFloat = 24
    }

    // MARK: - Corner Radius
    //
    // Radios de esquina consistentes para cada tipo de componente.
    // Fooco usa esquinas redondeadas — transmite calidez, no rigidez clínica.

    enum Radius {
        /// 6pt — botones pequeños, chips, badges
        static let sm: CGFloat = 6
        /// 10pt — campos de texto, botones medianos
        static let md: CGFloat = 10
        /// 16pt — cards principales, sheets
        static let card: CGFloat = 16
        /// 20pt — cards destacadas, modal bottom sheets
        static let cardLg: CGFloat = 20
        /// 24pt — componentes hero, banners
        static let hero: CGFloat = 24
        /// 999pt — píldoras (capsule)
        static let pill: CGFloat = 999
    }

    // MARK: - Font Size
    //
    // Escala tipográfica. Mínimo 16pt para cuerpo (HIG de Apple).
    // Proporciones basadas en la escala modular de 1.25 (Major Third).

    enum FontSize {
        /// 11pt — etiquetas muy pequeñas, footnotes
        static let caption2: CGFloat = 11
        /// 12pt — captions, metadatos secundarios
        static let caption: CGFloat = 12
        /// 13pt — texto de apoyo, timestamps
        static let footnote: CGFloat = 13
        /// 15pt — texto secundario, descripciones
        static let subheadline: CGFloat = 15
        /// 17pt — cuerpo principal (estándar iOS)
        static let body: CGFloat = 17
        /// 16pt — llamadas a la acción, botones
        static let callout: CGFloat = 16
        /// 20pt — títulos de sección
        static let title3: CGFloat = 20
        /// 22pt — títulos medianos
        static let title2: CGFloat = 22
        /// 28pt — títulos principales
        static let title: CGFloat = 28
        /// 34pt — números grandes (calorías totales, peso)
        static let largeTitle: CGFloat = 34
        /// 48pt — número hero (meta calórica del día)
        static let hero: CGFloat = 48
    }

    // MARK: - Icon Size

    enum IconSize {
        /// 16pt — iconos inline con texto
        static let sm: CGFloat = 16
        /// 20pt — iconos de lista
        static let md: CGFloat = 20
        /// 24pt — iconos de navegación, acciones
        static let lg: CGFloat = 24
        /// 32pt — iconos de categoría
        static let xl: CGFloat = 32
        /// 48pt — iconos de estado vacío
        static let xxl: CGFloat = 48
    }

    // MARK: - Animation
    //
    // Duraciones y curvas de animación.
    // Consistencia en las transiciones = app que se siente pulida.

    enum Animation {
        /// 150ms — micro-interacciones (tap feedback, toggle)
        static let fast: Double = 0.15
        /// 250ms — transiciones de estado (loading → results)
        static let normal: Double = 0.25
        /// 350ms — transiciones de pantalla, modals
        static let slow: Double = 0.35
        /// 500ms — animaciones de entrada destacadas
        static let emphasis: Double = 0.5
    }

    // MARK: - Component Sizes

    enum ComponentSize {
        /// Altura mínima de tap target (HIG: 44pt mínimo)
        static let minTapTarget: CGFloat = 44
        /// Altura de botón primario
        static let buttonHeight: CGFloat = 52
        /// Altura de campo de texto
        static let textFieldHeight: CGFloat = 52
        /// Altura de celda de lista estándar
        static let listRowHeight: CGFloat = 72
        /// Altura de tab bar
        static let tabBarHeight: CGFloat = 83
        /// Altura de search bar
        static let searchBarHeight: CGFloat = 44
    }
}
