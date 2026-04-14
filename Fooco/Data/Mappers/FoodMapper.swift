// MARK: - FoodMapper.swift
//
// Convierte DTOs de USDA en entidades de dominio.
//
// Produce dos tipos de entidades:
//   Food       → de búsqueda (macros principales)
//   FoodDetail → bajo demanda (categoría, porciones, minerales, vitaminas, grasas)
//
// ¿Por qué enum sin casos?
// El mapper no tiene estado — es una colección de funciones puras.
// Un enum sin casos no se puede instanciar: es un namespace de utilidades.

import Foundation

// MARK: - Constantes de nutrientes USDA

/// IDs de nutrientes según la base de datos USDA FoodData Central.
///
/// Usados en el endpoint de **detalle** (`/food/{fdcId}`):
/// corresponden al campo `id` dentro del objeto `nutrient` anidado.
///
/// Referencia: https://fdc.nal.usda.gov/api-guide
private enum NutrientID {
    // Macros principales
    static let calories: Int = 1008  // Energía (kcal)
    static let protein:  Int = 1003  // Proteína (g)
    static let fat:      Int = 1004  // Grasa total (g)
    static let carbs:    Int = 1005  // Carbohidratos (g)
    static let fiber:    Int = 1079  // Fibra dietética (g)
    static let sugar:    Int = 2000  // Azúcares totales (g)
    static let sodium:   Int = 1093  // Sodio (mg)

    // Minerales (mg, excepto selenium µg)
    static let calcium:    Int = 1087
    static let iron:       Int = 1089
    static let magnesium:  Int = 1090
    static let phosphorus: Int = 1091
    static let potassium:  Int = 1092
    static let zinc:       Int = 1095

    // Vitaminas
    static let vitaminC:   Int = 1162  // mg
    static let vitaminB6:  Int = 1175  // mg
    static let folate:     Int = 1190  // µg DFE
    static let vitaminB12: Int = 1178  // µg
    static let vitaminA:   Int = 1106  // µg RAE

    // Grasas desglosadas (g)
    static let saturatedFat:       Int = 1258
    static let monounsaturatedFat: Int = 1292
    static let polyunsaturatedFat: Int = 1293
}


// MARK: - FoodMapper

/// Convierte DTOs de la API de USDA en entidades de dominio.
enum FoodMapper {

    // MARK: - Búsqueda → [Food] con paginación

    /// Convierte la respuesta completa de búsqueda en una página de resultados.
    ///
    /// - Parameter dto: Respuesta del endpoint GET /foods/search
    /// - Returns: `FoodSearchPage` con los alimentos mapeados e información de paginación.
    static func map(_ dto: FoodSearchResponseDTO) -> FoodSearchPage {
        FoodSearchPage(
            foods:       dto.foods.map { map($0) },
            currentPage: dto.currentPage,
            totalPages:  dto.totalPages
        )
    }

    /// Convierte un item individual de búsqueda en una entidad Food.
    static func map(_ dto: FoodSearchItemDTO) -> Food {
        Food(
            id:        dto.fdcId,
            name:      dto.description,
            dataType:  Food.DataType(rawString: dto.dataType),
            brand:     dto.brandOwner,
            nutrients: mapSearchNutrients(dto.foodNutrients)
        )
    }

    // MARK: - Detalle → Food (macros, para compatibilidad)

    /// Convierte la respuesta de detalle en una entidad Food con nutrientes completos.
    ///
    /// - Parameter dto: Respuesta del endpoint GET /food/{fdcId}
    /// - Returns: Entidad Food con perfil nutricional completo.
    static func map(_ dto: FoodDetailDTO) -> Food {
        Food(
            id:        dto.fdcId,
            name:      dto.description,
            dataType:  Food.DataType(rawString: dto.dataType),
            brand:     nil,
            nutrients: mapDetailNutrients(dto.foodNutrients)
        )
    }

    // MARK: - Detalle → FoodDetail (información ampliada)

    /// Convierte la respuesta de detalle en el modelo ampliado `FoodDetail`.
    ///
    /// Extrae: categoría, nombre científico, porciones, minerales, vitaminas, grasas desglosadas.
    ///
    /// - Parameter dto: Respuesta del endpoint GET /food/{fdcId}
    /// - Returns: `FoodDetail` listo para mostrar en la sección "Saber más".
    static func mapToFoodDetail(_ dto: FoodDetailDTO) -> FoodDetail {
        let portions = (dto.foodPortions ?? [])
            .sorted { ($0.sequenceNumber ?? Int.max) < ($1.sequenceNumber ?? Int.max) }
            .compactMap { p -> FoodPortion? in
                guard let id        = p.id,
                      let modifier  = p.modifier,
                      let grams     = p.gramWeight
                else { return nil }
                return FoodPortion(
                    id:         id,
                    modifier:   modifier,
                    gramWeight: grams,
                    amount:     p.amount ?? 1
                )
            }

        let scientificName = dto.foodAttributes?
            .first(where: { $0.name == "Scientific Name" })?
            .value

        return FoodDetail(
            fdcId:          dto.fdcId,
            category:       dto.foodCategory?.description,
            scientificName: scientificName,
            portions:       portions,
            extended:       mapExtendedNutrients(dto.foodNutrients)
        )
    }
}

// MARK: - Helpers privados

private extension FoodMapper {

    /// Extrae los nutrientes del formato de búsqueda (abridged).
    ///
    /// En búsqueda, cada nutriente lleva `nutrientId` (ID largo, ej. 1008),
    /// que coincide directamente con los valores de `NutrientID`.
    /// El valor del nutriente está en el campo `value` (no `amount`).
    static func mapSearchNutrients(_ nutrients: [SearchFoodNutrientDTO]?) -> Food.Nutrients {
        func value(for id: Int) -> Double? {
            nutrients?.first(where: { $0.nutrientId == id })?.value
        }

        return Food.Nutrients(
            calories: value(for: NutrientID.calories) ?? 0.0,
            protein:  value(for: NutrientID.protein)  ?? 0.0,
            fat:      value(for: NutrientID.fat)       ?? 0.0,
            carbs:    value(for: NutrientID.carbs)     ?? 0.0,
            fiber:    value(for: NutrientID.fiber),
            sugar:    value(for: NutrientID.sugar),
            sodium:   value(for: NutrientID.sodium)
        )
    }

    /// Extrae los nutrientes del formato de detalle (anidado).
    ///
    /// En detalle, el ID USDA está en `nutrient.id` y el valor en `amount`.
    static func mapDetailNutrients(_ nutrients: [DetailFoodNutrientDTO]?) -> Food.Nutrients {
        func value(for id: Int) -> Double? {
            nutrients?.first(where: { $0.nutrient?.id == id })?.amount
        }

        return Food.Nutrients(
            calories: value(for: NutrientID.calories) ?? 0.0,
            protein:  value(for: NutrientID.protein)  ?? 0.0,
            fat:      value(for: NutrientID.fat)       ?? 0.0,
            carbs:    value(for: NutrientID.carbs)     ?? 0.0,
            fiber:    value(for: NutrientID.fiber),
            sugar:    value(for: NutrientID.sugar),
            sodium:   value(for: NutrientID.sodium)
        )
    }

    /// Extrae minerales, vitaminas y desglose de grasas del formato de detalle.
    static func mapExtendedNutrients(_ nutrients: [DetailFoodNutrientDTO]?) -> ExtendedNutrients {
        func value(for id: Int) -> Double? {
            nutrients?.first(where: { $0.nutrient?.id == id })?.amount
        }

        return ExtendedNutrients(
            // Minerales
            calcium:    value(for: NutrientID.calcium),
            iron:       value(for: NutrientID.iron),
            magnesium:  value(for: NutrientID.magnesium),
            phosphorus: value(for: NutrientID.phosphorus),
            potassium:  value(for: NutrientID.potassium),
            zinc:       value(for: NutrientID.zinc),
            // Vitaminas
            vitaminC:   value(for: NutrientID.vitaminC),
            vitaminB6:  value(for: NutrientID.vitaminB6),
            folate:     value(for: NutrientID.folate),
            vitaminB12: value(for: NutrientID.vitaminB12),
            vitaminA:   value(for: NutrientID.vitaminA),
            // Grasas
            saturatedFat:       value(for: NutrientID.saturatedFat),
            monounsaturatedFat: value(for: NutrientID.monounsaturatedFat),
            polyunsaturatedFat: value(for: NutrientID.polyunsaturatedFat)
        )
    }
}
