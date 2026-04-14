# Fooco — Product Requirements Document

**Versión:** 0.1 (MVP)  
**Fecha:** 2026-04-08  
**Autor:** Arlin Ropero  

---

## 1. Visión del producto

Fooco (Food + Focus) es una app de seguimiento calórico para iOS que prioriza la **comodidad del usuario sobre la precisión absoluta**. El diferenciador principal es que cualquier persona — tenga báscula o no, sea nutricionista o no — pueda registrar lo que come sin que sea una experiencia frustrante.

El nombre viene de **Food Calories Counter**. Las dos O dan personalidad visual al logo (ojos, plato).

---

## 2. Problema que resuelve

Las apps de conteo calórico existentes (MyFitnessPal, Cronometer) asumen que el usuario:
- Sabe exactamente cuántos gramos comió
- Conoce los alimentos por su nombre en inglés o en una base de datos genérica
- Come comida occidental o de supermercado con código de barras

Fooco resuelve tres brechas:

1. **Cultural:** un tamal en Bogotá no es el mismo que en Medellín ni en México. El usuario puede definir *su* versión.
2. **De precisión:** no todo el mundo tiene báscula. El modo "puñado" permite estimar sin instrumentos.
3. **De flexibilidad:** ayuno intermitente, keto, atletas de alto rendimiento, comidas libres — la app no impone un patrón.

---

## 3. Usuarios objetivo

- Personas que quieren empezar a llevar un registro calórico sin experiencia previa en nutrición.
- Usuarios latinoamericanos con acceso a comidas típicas regionales no indexadas en USDA.
- Personas con patrones de alimentación no convencionales (ayuno, keto, múltiples comidas al día).
- Atletas que necesitan metas calóricas altas.

---

## 4. Modos de uso

| Modo | Almacenamiento | Historial | Precio |
|------|---------------|-----------|--------|
| Invitado | Local (dispositivo) | 3 días | Gratis |
| Cuenta gratuita | Local + básico en nube | 1 semana | Gratis |
| Suscripción Premium | Sync remoto completo | 3 meses | ~$2 USD/mes |

**Migración invitado → cuenta:** los datos locales se sincronizan en un upload inicial al crear la cuenta. No se pierden.

**Early adopters:** precio fijo bajo garantizado. Con el tiempo el precio para nuevos usuarios subirá y se agregarán más funciones premium.

---

## 5. Funcionalidades del MVP

### 5.1 Biblioteca de alimentos

- Búsqueda en la base de datos USDA FoodData Central (API).
- Alimentos marcados como **propios** del usuario (visualmente diferenciados).
- Base de datos default con mínimo **50 recetas típicas latinoamericanas** precargadas (con ingredientes y valores nutricionales de USDA).
- Con el tiempo: nuevas recetas precargadas como parte del crecimiento del producto.

### 5.2 Recetas personalizadas

El usuario puede:
- Tomar una receta precargada y **modificarla** con sus propios ingredientes y cantidades.
- Crear una receta desde cero con ingredientes y cantidades.
- Cada ingrediente se busca en USDA o en su biblioteca propia.
- Las calorías de la receta se calculan automáticamente sumando los ingredientes.

**Nota sobre especias:** las especias en cantidades normales de cocina no afectan significativamente las calorías (< 5 kcal por porción típica). Se pueden incluir o ignorar sin impacto relevante.

### 5.3 Registro diario

- Lista de entradas libre a lo largo del día.
- **Etiquetas predefinidas:** Desayuno, Almuerzo, Cena, Snack, Antojito, Desliz.
- **Etiqueta custom:** el usuario puede escribir la que quiera.
- Soporte para diferentes patrones: 2 comidas (ayuno intermitente), 7 comidas (hobbit), sin categorías.

### 5.4 Modos de entrada de porciones

Tres modos, el usuario elige el que le sea más cómodo:

| Modo | Ejemplo | Para quién |
|------|---------|------------|
| Exacto | 150g, 250ml | Tiene báscula o mide |
| Unidades comunes | 1 banano mediano, 1 taza de arroz | Cocina sin báscula |
| Puñado (Precision Nutrition) | 1 palma, 2 puños | No quiere medir nada |

**Método Puñado** (basado en Precision Nutrition, validado científicamente):

| Unidad | Tipo de alimento | Calorías aprox. |
|--------|-----------------|-----------------|
| Palma de la mano | Proteína (carne, pollo, pescado) | ~135 kcal |
| Mano ahuecada | Carbohidratos (arroz, pasta, frutas) | ~115 kcal |
| Puño cerrado | Verduras | ~25 kcal |
| Pulgar | Grasas (aceite, mantequilla, nueces) | ~95 kcal |

Se autoescala: manos más grandes = porciones más grandes = más calorías. No requiere báscula ni conocimiento previo.

### 5.5 Meta calórica

Dos caminos:

1. **Manual:** el usuario define su meta directamente.
2. **Calculada (Mifflin-St Jeor):**

```
Hombre: (10 × kg) + (6.25 × cm) − (5 × edad) + 5
Mujer:  (10 × kg) + (6.25 × cm) − (5 × edad) − 161
```

El resultado es el **BMR** (metabolismo basal). Se multiplica por el factor de actividad:

| Nivel | Factor |
|-------|--------|
| Sedentario | × 1.2 |
| Actividad ligera | × 1.375 |
| Actividad moderada | × 1.55 |
| Actividad intensa | × 1.725 |
| Atleta | × 1.9 |

El resultado final es el **TDEE** (calorías para mantener el peso actual).

Para bajar peso de forma sostenible: TDEE − 500 kcal/día ≈ −0.5 kg/semana.

**Importante:** el cálculo se presenta como *sugerencia*, nunca como obligación. El usuario puede ignorarlo y poner la meta que quiera. Se muestra con contexto amable: *"Hoy comes ~2800 kcal. ¿Qué tal si esta semana probamos con 2500?"*

Soporte para dietas especiales: keto, atletas con alta demanda calórica, ayuno intermitente.

### 5.6 Estadísticas

- Calorías consumidas vs. meta por día.
- Historial gráfico (según modo: 3 días / 1 semana / 3 meses).
- Registro de peso corporal (entrada manual + sincronización con HealthKit si el usuario lo autoriza).
- Comparación calorías consumidas vs. peso a lo largo del tiempo.
- **Futuro:** glucosa en sangre, sincronización con Apple Watch.

### 5.7 Notificaciones locales

- Recordatorio configurable para registrar comidas ("¿Ya registraste tu almuerzo?").
- Alertas opcionales configurables por el usuario (ej: "Llevas el 80% de tu meta calórica").
- El usuario decide qué notificaciones activa y a qué hora.

### 5.8 Perfil y configuración

- Datos personales: nombre, edad, peso, altura, nivel de actividad.
- Preferencia de unidades: gramos / libras / oz.
- Modo de porciones preferido.
- Configuración de notificaciones.
- Gestión de cuenta y suscripción.

---

## 6. Tabs de la app

```
[ Biblioteca ] [ Registro ] [ Estadísticas ] [ Perfil ]
```

---

## 7. Arquitectura técnica

- **Stack:** SwiftUI + Swift 6 + Clean Architecture
- **API:** USDA FoodData Central
- **Local:** SwiftData o Core Data (TBD)
- **Remoto (premium):** TBD (CloudKit o backend propio)
- **Health:** HealthKit (peso, pasos — opcional para el usuario)
- **Notificaciones:** UNUserNotificationCenter (local)
- **Futuro:** Vision framework (reconocimiento de alimentos por foto), HealthKit avanzado

---

## 8. Fuera del MVP

- Reconocimiento de alimentos por fotografía
- Sincronización con Apple Watch (glucosa, calorías quemadas)
- Macros detallados (no solo calorías — proteína, carbos, grasa)
- Modo social / compartir recetas entre usuarios
- Exportar datos a PDF o CSV

---

## 9. Notas de negocio

- El precio premium (~$2 USD/mes) es bajo intencionalmente para facilitar la adopción inicial.
- Los early adopters mantienen ese precio como recompensa por el apoyo temprano.
- El catálogo de recetas precargadas crece con el tiempo como diferenciador y razón para actualizar.
- Potencial futuro: subir el precio para nuevos usuarios a medida que el producto madura.
