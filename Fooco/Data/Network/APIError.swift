// MARK: - APIError.swift
//
// ¿Qué hace este archivo?
// Define todos los errores que puede lanzar la capa de red.
// En lugar de trabajar con errores genéricos (Error, NSError), creamos
// un tipo propio que describe exactamente qué salió mal.
//
// ¿Por qué un enum?
// Un enum con casos asociados es la forma idiomática en Swift de modelar
// un conjunto cerrado de posibilidades — exactamente lo que es una lista
// de errores de red. El compilador nos obliga a manejar todos los casos.
//
// ¿Dónde se usa?
// NetworkManager lo lanza → Repository lo captura → ViewModel decide qué
// mostrar al usuario.
//
// Localización:
// Los mensajes ya NO están hardcodeados. Usamos StringKey + Localizable.xcstrings
// para que el texto aparezca en el idioma del dispositivo del usuario.
// Para agregar un idioma nuevo basta con abrir Localizable.xcstrings en Xcode
// y añadir la traducción — sin tocar este archivo.

import Foundation

// MARK: - APIError

/// Errores tipados de la capa de red.
///
/// - `LocalizedError`: permite mensajes legibles en el idioma del usuario.
/// - `Equatable`: permite comparar errores en tests con `#expect(throws:)`.
///   Los casos con `Error` asociado comparan solo el caso, no el error interno,
///   porque `Error` no conforma a `Equatable`.
enum APIError: Error, LocalizedError, Equatable {

    // MARK: Casos

    /// La URL construida por el Router no es válida.
    /// Ejemplo: un path con caracteres ilegales.
    case invalidURL

    /// El servidor respondió con un código HTTP fuera del rango 200-299.
    /// Llevamos el código para poder reaccionar diferente a un 404 vs un 500.
    case httpError(statusCode: Int)

    /// URLSession devolvió datos nil sin lanzar error propio.
    /// Raro, pero puede pasar si el servidor cierra la conexión limpiamente
    /// sin enviar cuerpo.
    case noData

    /// `JSONDecoder` no pudo transformar el JSON en nuestro modelo.
    /// Guardamos el error original para facilitar el debugging.
    case decodingError(Error)

    /// Cualquier otro error de red (sin conexión, timeout, etc.).
    /// Envuelve el error de URLSession para no perder contexto.
    case networkError(Error)

    // MARK: - LocalizedError

    /// Mensaje legible para el usuario en su idioma.
    ///
    /// Las claves vienen de `StringKey.Error` y los valores del catálogo
    /// `Localizable.xcstrings`. iOS elige automáticamente el idioma
    /// según la configuración del dispositivo.
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            // Sin argumentos de formato — usamos el helper simple
            return localized(StringKey.Error.invalidURL)

        case .httpError(let statusCode):
            // %lld en el catálogo → sustituimos con el código HTTP
            return localized(StringKey.Error.httpError, args: statusCode)

        case .noData:
            return localized(StringKey.Error.noData)

        case .decodingError(let error):
            // %@ en el catálogo → sustituimos con la descripción del error
            return localized(StringKey.Error.decodingError, args: error.localizedDescription)

        case .networkError(let error):
            return localized(StringKey.Error.networkError, args: error.localizedDescription)
        }
    }

    // MARK: - Equatable

    /// Compara dos APIError por caso.
    /// Para `decodingError` y `networkError` ignoramos el error subyacente
    /// porque `Error` no conforma a `Equatable`.
    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):               return true
        case (.noData, .noData):                       return true
        case (.httpError(let a), .httpError(let b)):   return a == b
        case (.decodingError, .decodingError):         return true
        case (.networkError, .networkError):           return true
        default:                                       return false
        }
    }
}
