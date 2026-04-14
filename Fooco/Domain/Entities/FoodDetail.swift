// MARK: - FoodDetail.swift
//
// Modelo de dominio para el detalle ampliado de un alimento.
//
// ¿Cuándo se usa?
// Cuando el usuario toca "Saber más" en la pantalla de detalle.
// La búsqueda ya trae los macros principales (Food.Nutrients).
// FoodDetail agrega lo que el endpoint de detalle aporta extra:
//   - Categoría del alimento (ej: "Fats and Oils")
//   - Nombre científico (ej: "Persea americana")
//   - Porciones estándar (ej: "1 tbsp = 14 g")
//   - Minerales, vitaminas y desglose de grasas
//
// ¿Por qué separarlo de Food?
// Food es lo que necesita el 100% de las pantallas — lean y rápido.
// FoodDetail es lo que solo carga quien pide explícitamente "más info".
// Mezclarlos haría Food más pesado y requeriría la llamada extra siempre.

import Foundation

// MARK: - FoodDetail

/// Información ampliada de un alimento, cargada bajo demanda desde el endpoint de detalle.
struct FoodDetail: Sendable {

    /// ID del alimento en USDA — corresponde al `Food.id` del mismo alimento.
    let fdcId: Int

    /// Categoría del alimento según USDA. Ej: "Fats and Oils", "Poultry Products".
    let category: String?

    /// Nombre científico/taxonómico. Ej: "Persea americana" para el aguacate.
    let scientificName: String?

    /// Porciones estándar de medida. Ej: "1 tsp", "1 tbsp", "1 cup".
    let portions: [FoodPortion]

    /// Nutrientes extendidos: minerales, vitaminas, desglose de grasas.
    let extended: ExtendedNutrients
}

// MARK: - FoodPortion

/// Una porción de referencia para el alimento.
///
/// Permite al usuario entender cuántos gramos hay en medidas cotidianas
/// en lugar de pensar siempre en "100 g".
struct FoodPortion: Identifiable, Sendable {

    /// ID único de la porción en la base de datos USDA.
    let id: Int

    /// Descripción de la medida. Ej: "tsp", "tbsp", "cup", "oz".
    let modifier: String

    /// Peso en gramos de esta porción.
    let gramWeight: Double

    /// Cantidad de la unidad. Generalmente 1 (ej: "1 tbsp"), pero puede ser 2 o más.
    let amount: Double
}

// MARK: - ExtendedNutrients

/// Nutrientes adicionales disponibles en el endpoint de detalle.
///
/// Los campos son opcionales porque no todos los alimentos tienen
/// datos medidos para cada nutriente — la USDA lo indica con ausencia del campo.
struct ExtendedNutrients: Sendable {

    // MARK: Minerales (mg, excepto selenium en µg)

    /// Calcio — id USDA: 1087
    let calcium: Double?

    /// Hierro — id USDA: 1089
    let iron: Double?

    /// Magnesio — id USDA: 1090
    let magnesium: Double?

    /// Fósforo — id USDA: 1091
    let phosphorus: Double?

    /// Potasio — id USDA: 1092
    let potassium: Double?

    /// Zinc — id USDA: 1095
    let zinc: Double?

    // MARK: Vitaminas

    /// Vitamina C, ácido ascórbico total — mg — id USDA: 1162
    let vitaminC: Double?

    /// Vitamina B-6 — mg — id USDA: 1175
    let vitaminB6: Double?

    /// Folato DFE — µg — id USDA: 1190
    let folate: Double?

    /// Vitamina B-12 — µg — id USDA: 1178
    let vitaminB12: Double?

    /// Vitamina A, RAE — µg — id USDA: 1106
    let vitaminA: Double?

    // MARK: Desglose de grasas (g)

    /// Ácidos grasos saturados — id USDA: 1258
    let saturatedFat: Double?

    /// Ácidos grasos monoinsaturados — id USDA: 1292
    let monounsaturatedFat: Double?

    /// Ácidos grasos poliinsaturados — id USDA: 1293
    let polyunsaturatedFat: Double?
}
