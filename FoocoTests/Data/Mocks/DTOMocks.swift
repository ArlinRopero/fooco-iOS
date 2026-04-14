// MARK: - DTOMocks.swift
//
// ¿Qué son los mocks de DTOs?
// Datos de prueba que simulan exactamente lo que devolvería la API real.
// Dos formatos:
//
//   1. JSON strings  → para testear que JSONDecoder decodifica bien
//   2. Instancias    → para testear el mapper sin pasar por JSON
//
// ¿Por qué separar los mocks en su propio archivo?
// Porque múltiples archivos de test los necesitan. Sin este archivo
// cada test tendría que repetir los mismos datos — violando DRY.
//
// Los valores nutricionales son los reales del aguacate según USDA
// (fdcId: 171705) para que los tests tengan significado real.

import Foundation
@testable import Fooco

// MARK: - DTOMocks

enum DTOMocks {

    // MARK: - JSON Strings

    /// JSON real del endpoint de búsqueda con un resultado (aguacate).
    /// Refleja exactamente la estructura que devuelve la API de USDA FoodData Central v1.
    /// Campos confirmados: nutrientId (Int), nutrientName (String), nutrientNumber (String), value (Double).
    static let searchResponseJSON = """
    {
        "totalHits": 42,
        "currentPage": 1,
        "totalPages": 3,
        "foods": [
            {
                "fdcId": 171705,
                "description": "Avocado, raw",
                "dataType": "Foundation",
                "publicationDate": "2019-04-01",
                "brandOwner": null,
                "foodNutrients": [
                    { "nutrientId": 1008, "nutrientName": "Energy",              "nutrientNumber": "208", "value": 160.0, "unitName": "KCAL" },
                    { "nutrientId": 1003, "nutrientName": "Protein",             "nutrientNumber": "203", "value": 2.0,   "unitName": "G"    },
                    { "nutrientId": 1004, "nutrientName": "Total lipid (fat)",   "nutrientNumber": "204", "value": 14.66, "unitName": "G"    },
                    { "nutrientId": 1005, "nutrientName": "Carbohydrate",        "nutrientNumber": "205", "value": 8.53,  "unitName": "G"    },
                    { "nutrientId": 1079, "nutrientName": "Fiber",               "nutrientNumber": "291", "value": 6.7,   "unitName": "G"    },
                    { "nutrientId": 2000, "nutrientName": "Sugars",              "nutrientNumber": "269", "value": 0.66,  "unitName": "G"    },
                    { "nutrientId": 1093, "nutrientName": "Sodium",              "nutrientNumber": "307", "value": 7.0,   "unitName": "MG"   }
                ]
            }
        ]
    }
    """

    /// JSON de un alimento sin nutrientes — caso límite importante.
    /// La API puede devolver items sin `foodNutrients` en búsqueda.
    static let searchItemWithoutNutrientsJSON = """
    {
        "totalHits": 1,
        "currentPage": 1,
        "totalPages": 1,
        "foods": [
            {
                "fdcId": 999999,
                "description": "Mystery Food",
                "dataType": "SR Legacy"
            }
        ]
    }
    """

    /// JSON del endpoint de detalle (formato anidado — estructura real de la API).
    static let detailResponseJSON = """
    {
        "fdcId": 171705,
        "description": "Avocado, raw",
        "dataType": "Foundation",
        "publicationDate": "2019-04-01",
        "foodNutrients": [
            { "amount": 160.0, "nutrient": { "id": 1008, "number": "208", "name": "Energy",            "unitName": "kcal", "rank": 300  } },
            { "amount": 2.0,   "nutrient": { "id": 1003, "number": "203", "name": "Protein",           "unitName": "g",    "rank": 600  } },
            { "amount": 14.66, "nutrient": { "id": 1004, "number": "204", "name": "Total lipid (fat)", "unitName": "g",    "rank": 800  } },
            { "amount": 8.53,  "nutrient": { "id": 1005, "number": "205", "name": "Carbohydrate",      "unitName": "g",    "rank": 1110 } },
            { "amount": 6.7,   "nutrient": { "id": 1079, "number": "291", "name": "Fiber",             "unitName": "g",    "rank": 1200 } },
            { "amount": 0.66,  "nutrient": { "id": 2000, "number": "269", "name": "Sugars",            "unitName": "g",    "rank": 1510 } },
            { "amount": 7.0,   "nutrient": { "id": 1093, "number": "307", "name": "Sodium",            "unitName": "mg",   "rank": 5800 } }
        ]
    }
    """

    // MARK: - Instancias de DTOs

    /// Nutrientes en formato búsqueda (SearchFoodNutrientDTO).
    /// Usa los campos reales de la API: nutrientId (Int largo), value (Double).
    static let searchNutrients: [SearchFoodNutrientDTO] = [
        SearchFoodNutrientDTO(nutrientId: 1008, nutrientName: "Energy",            nutrientNumber: "208", value: 160.0, unitName: "KCAL"),
        SearchFoodNutrientDTO(nutrientId: 1003, nutrientName: "Protein",           nutrientNumber: "203", value: 2.0,   unitName: "G"),
        SearchFoodNutrientDTO(nutrientId: 1004, nutrientName: "Total lipid (fat)", nutrientNumber: "204", value: 14.66, unitName: "G"),
        SearchFoodNutrientDTO(nutrientId: 1005, nutrientName: "Carbohydrate",      nutrientNumber: "205", value: 8.53,  unitName: "G"),
        SearchFoodNutrientDTO(nutrientId: 1079, nutrientName: "Fiber",             nutrientNumber: "291", value: 6.7,   unitName: "G"),
        SearchFoodNutrientDTO(nutrientId: 2000, nutrientName: "Sugars",            nutrientNumber: "269", value: 0.66,  unitName: "G"),
        SearchFoodNutrientDTO(nutrientId: 1093, nutrientName: "Sodium",            nutrientNumber: "307", value: 7.0,   unitName: "MG")
    ]

    /// Item de búsqueda completo (aguacate).
    static let avocadoSearchItem = FoodSearchItemDTO(
        fdcId:           171705,
        description:     "Avocado, raw",
        dataType:        "Foundation",
        publicationDate: "2019-04-01",
        brandOwner:      nil,
        foodNutrients:   searchNutrients
    )

    /// Item de búsqueda sin nutrientes (caso límite).
    static let itemWithoutNutrients = FoodSearchItemDTO(
        fdcId:           999999,
        description:     "Mystery Food",
        dataType:        "SR Legacy",
        publicationDate: nil,
        brandOwner:      nil,
        foodNutrients:   nil
    )

    /// Item de búsqueda de producto de marca.
    static let brandedItem = FoodSearchItemDTO(
        fdcId:           888888,
        description:     "Organic Almond Butter",
        dataType:        "Branded",
        publicationDate: nil,
        brandOwner:      "Whole Foods Market",
        foodNutrients:   nil
    )

    /// Respuesta completa de búsqueda.
    static let searchResponse = FoodSearchResponseDTO(
        totalHits:   42,
        currentPage: 1,
        totalPages:  3,
        foods:       [avocadoSearchItem]
    )

    /// Nutrientes en formato detalle (DetailFoodNutrientDTO — estructura anidada real).
    static let detailNutrients: [DetailFoodNutrientDTO] = [
        DetailFoodNutrientDTO(amount: 160.0,  nutrient: NutrientInfoDTO(id: 1008, number: "208", name: "Energy",            unitName: "kcal", rank: 300)),
        DetailFoodNutrientDTO(amount: 2.0,    nutrient: NutrientInfoDTO(id: 1003, number: "203", name: "Protein",           unitName: "g",    rank: 600)),
        DetailFoodNutrientDTO(amount: 14.66,  nutrient: NutrientInfoDTO(id: 1004, number: "204", name: "Total lipid (fat)", unitName: "g",    rank: 800)),
        DetailFoodNutrientDTO(amount: 8.53,   nutrient: NutrientInfoDTO(id: 1005, number: "205", name: "Carbohydrate",      unitName: "g",    rank: 1110)),
        DetailFoodNutrientDTO(amount: 6.7,    nutrient: NutrientInfoDTO(id: 1079, number: "291", name: "Fiber",             unitName: "g",    rank: 1200)),
        DetailFoodNutrientDTO(amount: 0.66,   nutrient: NutrientInfoDTO(id: 2000, number: "269", name: "Sugars",            unitName: "g",    rank: 1510)),
        DetailFoodNutrientDTO(amount: 7.0,    nutrient: NutrientInfoDTO(id: 1093, number: "307", name: "Sodium",            unitName: "mg",   rank: 5800))
    ]

    /// Respuesta completa de detalle (aguacate).
    static let avocadoDetail = FoodDetailDTO(
        fdcId:           171705,
        description:     "Avocado, raw",
        dataType:        "Foundation",
        publicationDate: "2019-04-01",
        foodNutrients:   detailNutrients,
        foodCategory: nil,
        foodPortions: [],
        foodAttributes: []
    )
}
