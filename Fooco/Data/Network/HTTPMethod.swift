// MARK: - HTTPMethod.swift
//
// ¿Qué hace este archivo?
// Define los métodos HTTP que usará la app como un enum tipado.
//
// ¿Por qué no usar strings directos?
// Escribir "GET", "POST", etc. como String literals en el código es
// propenso a typos y no te da autocompletado. Con un enum:
//   ✅ El compilador atrapa "GETT" en tiempo de compilación.
//   ✅ Autocompletado en Xcode.
//   ✅ Un solo lugar donde están definidos todos los métodos soportados.
//
// ¿Dónde se usa?
// El protocolo Router lo expone como propiedad → NetworkManager lo lee
// para configurar el URLRequest → URLSession lo envía.
//
// Flujo:
//   FoodRouter.search → method: .get
//       ↓
//   NetworkManager → request.httpMethod = method.rawValue  →  "GET"
//       ↓
//   URLSession

// MARK: - HTTPMethod

/// Métodos HTTP soportados por la app.
///
/// - `rawValue`: el string que URLSession espera en `request.httpMethod`.
/// - `CaseIterable`: permite iterar todos los casos en tests parametrizados.
///   Swift sintetiza `allCases` automáticamente — no necesitamos código extra.
/// Por convención HTTP (RFC 7231) los métodos van en mayúsculas.
enum HTTPMethod: String, CaseIterable {

    /// Obtener un recurso. No modifica estado en el servidor.
    /// Ejemplo: buscar alimentos, traer detalle de un plato.
    case get    = "GET"

    /// Crear un recurso nuevo en el servidor.
    /// Ejemplo: guardar un alimento favorito en una API propia.
    case post   = "POST"

    /// Reemplazar un recurso existente por completo.
    case put    = "PUT"

    /// Actualizar parcialmente un recurso existente.
    case patch  = "PATCH"

    /// Eliminar un recurso del servidor.
    case delete = "DELETE"
}
