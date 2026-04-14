# Fooco — Arquitectura Técnica

**Versión:** 0.3  
**Última actualización:** 2026-04-10  

> Decisiones técnicas, estructura de capas y convenciones de código del proyecto.

---

## Tabla de contenidos

1. [Principios de arquitectura](#1-principios-de-arquitectura)
2. [Capas del sistema](#2-capas-del-sistema)
3. [Estructura de carpetas](#3-estructura-de-carpetas)
4. [Fuente de datos](#4-fuente-de-datos)
5. [Persistencia local](#5-persistencia-local)
6. [Concurrencia](#6-concurrencia)
7. [Localización](#7-localización)
8. [Testing](#8-testing)
9. [Convenciones de código](#9-convenciones-de-código)
10. [Decisiones técnicas clave](#10-decisiones-técnicas-clave)

---

## 1. Principios de arquitectura

- **Clean Architecture.** Domain no conoce Data ni Presentation. Data implementa contratos del Domain. Presentation consume UseCases.
- **Protocol-Oriented DI.** Todas las dependencias se inyectan como protocolos — facilita mocks en tests sin frameworks externos.
- **Inmutabilidad por defecto.** `struct` + `let` en todas partes. `class` solo cuando el compilador lo exige (SwiftData `@Model`).
- **Un UseCase, una responsabilidad.** Cada UseCase hace exactamente una cosa. Nada de lógica mezclada.
- **Sin frameworks de terceros.** SwiftUI + SwiftData + Swift Concurrency nativos. Zero dependencias externas.

---

## 2. Capas del sistema

```
┌─────────────────────────────────────────┐
│            Presentation                 │
│   ViewModels (@Observable @MainActor)   │
│   Views (SwiftUI)                       │
└───────────────────┬─────────────────────┘
                    │ depende de
┌───────────────────▼─────────────────────┐
│               Domain                    │
│   Entities (struct, Sendable)           │
│   UseCases (struct + protocol)          │
│   Repository Protocols                  │
└───────────────────┬─────────────────────┘
                    │ implementado por
┌───────────────────▼─────────────────────┐
│                 Data                    │
│   Repositories (actor / @ModelActor)   │
│   Mappers (enum sin casos)              │
│   DTOs (Codable structs)               │
│   Network (NetworkManager, Routers)     │
│   Models (SwiftData @Model)             │
└─────────────────────────────────────────┘
```

**Regla de dependencia:** las flechas solo apuntan hacia adentro (hacia Domain). Nunca al revés.

---

## 3. Estructura de carpetas

```
Fooco/
├── Core/
│   ├── APIConfig.swift              # Lee api_key de Secrets.xcconfig
│   ├── Constants/
│   │   └── AppConstants.swift       # Spacing, radius, font sizes, etc.
│   ├── Theme/
│   │   └── AppColors.swift          # Paleta semántica
│   └── Localization/
│       └── StringKey.swift          # Todas las claves de localización tipadas
│
├── Domain/
│   ├── Entities/
│   │   ├── Food.swift               # Alimento con nutrientes
│   │   ├── FoodDetail.swift         # Detalle ampliado (bajo demanda)
│   │   ├── LogEntry.swift           # Registro de consumo
│   │   └── FoodSearchPage.swift     # Paginación de búsqueda
│   ├── Repositories/
│   │   ├── FoodRepositoryProtocol.swift
│   │   └── FoodLogRepositoryProtocol.swift
│   └── UseCases/
│       ├── SearchFoodUseCase.swift
│       ├── GetFoodDetailUseCase.swift
│       ├── LogFoodUseCase.swift
│       ├── GetTodayEntriesUseCase.swift
│       ├── GetWeeklyEntriesUseCase.swift
│       └── GetFrequentFoodsUseCase.swift
│
├── Data/
│   ├── Network/
│   │   ├── NetworkManager.swift     # Actor + URLSession + debug logging
│   │   ├── Router.swift             # Protocolo base de routing
│   │   ├── FoodRouter.swift         # Endpoints USDA
│   │   ├── HTTPMethod.swift
│   │   └── APIError.swift
│   ├── DTOs/
│   │   ├── FoodSearchResponseDTO.swift   # Formato búsqueda
│   │   └── FoodDetailDTO.swift           # Formato detalle
│   ├── Repositories/
│   │   ├── FoodRepository.swift     # Llama NetworkManager
│   │   └── FoodLogRepository.swift  # @ModelActor + SwiftData
│   ├── Models/
│   │   └── LogEntryModel.swift      # @Model para SwiftData
│   ├── Mappers/
│   │   ├── FoodMapper.swift         # DTO → Food / FoodDetail
│   │   └── LogEntryMapper.swift     # LogEntry ↔ LogEntryModel
│   └── Services/
│       ├── AppleQueryTranslator.swift      # Traduce búsqueda al inglés
│       └── AppleFoodNameTranslator.swift   # Traduce nombre del alimento
│
├── Presentation/
│   ├── ViewModels/
│   │   ├── SearchViewModel.swift
│   │   ├── FoodDetailViewModel.swift
│   │   └── LogViewModel.swift
│   └── Views/
│       ├── Main/MainTabView.swift
│       ├── Search/
│       │   ├── SearchView.swift
│       │   └── FoodRowView.swift
│       ├── Detail/
│       │   └── FoodDetailView.swift
│       └── Log/
│           └── LogView.swift
│
└── Resources/
    ├── Localizable.xcstrings
    └── Assets.xcassets
```

---

## 4. Fuente de datos

### USDA FoodData Central API v1

| Endpoint | Uso | Parámetros clave |
|---|---|---|
| `GET /foods/search` | Búsqueda por texto | `query`, `pageSize=10`, `pageNumber` |
| `GET /food/{fdcId}` | Detalle de un alimento | `fdcId` |

**Autenticación:** `api_key` como query param. La key vive en `Secrets.xcconfig` (no comiteada).

### Estructura real del JSON de búsqueda

```json
// foodNutrients[i] en /foods/search
{
  "nutrientId": 1008,        // Int — ID largo (mismo que en detalle)
  "nutrientName": "Energy",  // String
  "nutrientNumber": "208",   // String — código corto (no se usa para comparar)
  "value": 160.0,            // Double — cantidad por 100g
  "unitName": "KCAL"         // String
}
```

### Estructura real del JSON de detalle

```json
// foodNutrients[i] en /food/{fdcId}
{
  "amount": 160.0,
  "nutrient": {
    "id": 1008,             // Int — ID largo
    "number": "208",        // String — código corto
    "name": "Energy",
    "unitName": "kcal",
    "rank": 300
  }
}
```

> **Nota importante:** Los dos endpoints tienen estructuras distintas.
> El mapper de búsqueda usa `nutrientId` + `value`.
> El mapper de detalle usa `nutrient.id` + `amount`.

### IDs de nutrientes relevantes (NutrientID)

| ID | Nutriente | Unidad |
|---|---|---|
| 1008 | Energía | kcal |
| 1003 | Proteína | g |
| 1004 | Grasa total | g |
| 1005 | Carbohidratos | g |
| 1079 | Fibra | g |
| 2000 | Azúcares | g |
| 1093 | Sodio | mg |
| 1087 | Calcio | mg |
| 1089 | Hierro | mg |
| 1090 | Magnesio | mg |
| 1091 | Fósforo | mg |
| 1092 | Potasio | mg |
| 1095 | Zinc | mg |
| 1162 | Vitamina C | mg |
| 1175 | Vitamina B6 | mg |
| 1190 | Folato | µg |
| 1178 | Vitamina B12 | µg |
| 1106 | Vitamina A | µg |
| 1258 | Grasa saturada | g |
| 1292 | Grasa monoinsaturada | g |
| 1293 | Grasa poliinsaturada | g |

---

## 5. Persistencia local

### SwiftData

Modelos persistidos:

| @Model | Propósito |
|---|---|
| `LogEntryModel` | Registro de consumo de un alimento |
| `UserProfileModel` | Datos del perfil de usuario *(próximo)* |
| `TrackedNutrientModel` | Nutrientes que el usuario quiere monitorear *(próximo)* |

### LogEntryModel — campos

```swift
@Model final class LogEntryModel {
    var id: UUID
    var fdcId: Int
    var foodName: String
    var grams: Double
    var loggedAt: Date
    // Nutrientes aplanados (valores por 100g al momento del registro)
    var calories: Double
    var protein: Double
    var fat: Double
    var carbs: Double
    var fiber: Double?
    var sugar: Double?
    var sodium: Double?
    // Extendidos (de "Saber más", si el usuario lo cargó)
    var iron: Double?
    var magnesium: Double?
    var calcium: Double?
    // ... etc.
}
```

### ¿Por qué campos aplanados en lugar de relaciones?

SwiftData no soporta `Food` como propiedad directa de un `@Model` (violaría Clean Architecture). Se aplanan todos los valores en el momento del registro para tener una snapshot inmutable de los datos nutricionales.

### FoodLogRepository — patrón @ModelActor

```swift
@ModelActor
actor FoodLogRepository: FoodLogRepositoryProtocol {
    // ModelContext propio, background thread, Swift 6 safe
}
```

---

## 6. Concurrencia

- **Swift 6 strict concurrency** habilitado en todo el proyecto.
- ViewModels: `@Observable @MainActor final class`
- Repositories: `actor` o `@ModelActor`
- Entities, DTOs, Mappers: `struct + Sendable`
- UseCases: `struct + Sendable` (sin estado)
- Llamadas paralelas con `async let` donde los datos son independientes.

```swift
// Ejemplo en LogViewModel
async let today  = getTodayEntriesUseCase.execute()
async let weekly = getWeeklyEntriesUseCase.execute()
let (todayResult, weeklyResult) = try await (today, weekly)
```

---

## 7. Localización

- Archivo: `Localizable.xcstrings` (formato Xcode 15+)
- Idiomas: `es-419` (fuente principal), `en`, `pt-BR`, `pt-PT`
- Todas las claves tipadas en `StringKey.swift` — nunca strings literales dispersos.
- Los textos de la UI usan `LocalizedStringKey` directamente en SwiftUI.

```swift
// Bien
Text("detail.calories.label")      // SwiftUI localiza automáticamente

// Bien (programático)
localized(StringKey.Error.noData)  // helper para strings en código

// Mal
Text("Calorías")                   // hardcoded, no localizable
```

---

## 8. Testing

### Framework

Swift Testing (`import Testing`) para todos los tests nuevos.

### Cobertura mínima

80% en Domain y Data. Presentation se testea con ViewModels (no con vistas).

### Patrones de mock

- **Spy + Stub:** `MockFoodLogRepository`, `MockFoodRepository`, `MockNetworkManager`
- **In-Memory:** los mocks implementan el mismo protocolo que la implementación real
- **No mocking de SwiftData:** los mappers se testean con instancias directas

### Organización de tests

```
FoocoTests/
├── Domain/
│   ├── Mocks/           # MockFoodRepository, MockFoodLogRepository, FoodMocks
│   ├── FoodEntityTests.swift
│   ├── LogFoodUseCaseTests.swift
│   ├── SearchFoodUseCaseTests.swift
│   ├── GetTodayEntriesUseCaseTests.swift
│   ├── GetWeeklyEntriesUseCaseTests.swift
│   └── GetFrequentFoodsUseCaseTests.swift
├── Data/
│   ├── Mocks/           # DTOMocks, MockNetworkManager, MockURLProtocol
│   ├── DTODecodingTests.swift
│   ├── FoodMapperTests.swift
│   ├── FoodRepositoryTests.swift
│   └── LogEntryMapperTests.swift
└── Presentation/
    ├── SearchViewModelTests.swift
    ├── FoodDetailViewModelLogTests.swift
    └── LogViewModelTests.swift
```

---

## 9. Convenciones de código

| Elemento | Convención |
|---|---|
| ViewModels | `@Observable @MainActor final class NombreViewModel` |
| Views | `struct NombreView: View` |
| UseCases | `struct NombreUseCase: NombreUseCaseProtocol` |
| Repositories (protocolo) | `protocol NombreRepositoryProtocol: Sendable` |
| Repositories (impl) | `@ModelActor actor NombreRepository` o `actor` |
| Mappers | `enum NombreMapper` (namespace puro, sin casos) |
| DTOs | `struct NombreDTO: Codable, Sendable` |
| Models SwiftData | `@Model final class NombreModel` |
| Entities dominio | `struct Nombre: Sendable` |
| Constantes | `private enum NombreConstante { static let x = ... }` |

---

## 10. Decisiones técnicas clave

### ¿Por qué sin CocoaPods/SPM/Carthage?

Cero dependencias externas en el MVP. SwiftUI + SwiftData + Swift Concurrency cubren todos los casos. Menos dependencias = menos fricciones de build, menos vectores de ataque de seguridad, más control.

### ¿Por qué `@ModelActor` y no `@MainActor` para SwiftData?

`@ModelActor` crea un actor dedicado con `ModelContext` propio en background. Permite leer/escribir en SwiftData sin bloquear el hilo principal. Es el patrón recomendado por Apple desde iOS 17.

### ¿Por qué los nutrientes se aplanan en `LogEntryModel`?

SwiftData no soporta tipos de dominio (`Food`, `Food.Nutrients`) como propiedades de un `@Model`. Aplanar garantiza que la snapshot del alimento al momento del registro sea inmutable e independiente de cambios futuros en la API.

### ¿Por qué `SearchNutrientNumber` fue eliminado?

La API de búsqueda devuelve `nutrientId` (ej. 1008), no el código corto (ej. 208). El intento de usar códigos cortos (208, 203...) era erróneo. El fix correcto fue actualizar `SearchFoodNutrientDTO` para mapear los campos reales (`nutrientId`, `value`) y usar `NutrientID` en el mapper.

### ¿Por qué no se carga el detalle automáticamente al abrir un alimento?

El endpoint de búsqueda ya devuelve macros suficientes para la vista de detalle básica. Cargar el detalle siempre duplicaba el tiempo de respuesta percibido sin añadir valor en el 80% de los casos. "Saber más" es el 20% que sí lo necesita.

---

*Documento vivo — se actualiza con cada decisión técnica significativa.*
