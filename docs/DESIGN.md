# Fooco — Decisiones de Diseño de Producto

**Versión:** 0.3  
**Última actualización:** 2026-04-10  
**Autor:** Arlin Ropero  

> Este documento captura las decisiones de producto y UX tomadas en sesiones de diseño conversacional. Sirve como fuente de verdad antes de escribir código.

---

## Tabla de contenidos

1. [Principios generales](#1-principios-generales)
2. [Navegación principal](#2-navegación-principal)
3. [Búsqueda de alimentos](#3-búsqueda-de-alimentos)
4. [Detalle de alimento](#4-detalle-de-alimento)
5. [Registro diario](#5-registro-diario)
6. [Estadísticas](#6-estadísticas)
7. [Perfil de usuario](#7-perfil-de-usuario)

---

## 1. Principios generales

- **Comodidad sobre precisión.** El usuario no necesita báscula ni conocimientos de nutrición para usar la app.
- **Sin juicios.** La app muestra información; el usuario decide. No hay mensajes de culpa ni de alerta paternalista.
- **Personalización progresiva.** La app funciona desde el primer día sin ningún dato de perfil. A medida que el usuario agrega información, la experiencia mejora.
- **Evolutivo consciente.** Las funciones complejas se diseñan pensando en el futuro, pero no se implementan antes de tiempo. Cada feature tiene un estado claro: MVP, próximo, o evolutivo.

---

## 2. Navegación principal

Cuatro tabs:

| Tab | Ícono | Estado |
|---|---|---|
| Biblioteca (búsqueda) | `magnifyingglass` | ✅ MVP |
| Registro | `fork.knife` | ✅ MVP |
| Estadísticas | `chart.bar.fill` | 🔨 En construcción |
| Perfil | `person.fill` | 🔨 En construcción |

---

## 3. Búsqueda de alimentos

### Paginación
- **10 resultados por página.** La búsqueda inicial trae 10 items.
- **Scroll infinito.** Al llegar al final de la lista, se carga automáticamente la siguiente página (pull-up = load more).
- Decisión: velocidad percibida > exhaustividad. 10 resultados es suficiente para la mayoría de búsquedas.

### Traducción
- La query de búsqueda se traduce automáticamente al inglés antes de consultar USDA.
- El nombre del alimento en el resultado se traduce al idioma del dispositivo.
- El nombre traducido reemplaza el nombre en inglés en toda la UI (detalle, registro, historial).

### Fuente de datos
- API: USDA FoodData Central v1 (`/foods/search`)
- Los nutrientes vienen en el resultado de búsqueda: `nutrientId` (Int), `value` (Double).
- **No se hace una llamada adicional al abrir un alimento.** Los datos de búsqueda son suficientes para la vista de detalle básica.

---

## 4. Detalle de alimento

### Datos que se muestran desde búsqueda (siempre disponibles)
- Nombre (traducido)
- Calorías por 100g
- Macros: proteína, carbohidratos, grasa

### Sección "Saber más" (carga bajo demanda)
- Se activa con un botón. No se carga automáticamente.
- Llama al endpoint `/food/{fdcId}` solo cuando el usuario lo solicita.
- Muestra:
  - Categoría del alimento
  - Nombre científico (si existe)
  - Porciones de referencia (cucharada, taza, etc.)
  - Minerales: calcio, hierro, magnesio, fósforo, potasio, zinc
  - Vitaminas: C, B6, folato, B12, A
  - Desglose de grasas: saturadas, monoinsaturadas, poliinsaturadas
- Una vez cargado, se cachea en memoria (no vuelve a hacer fetch si el usuario ya lo abrió).

### Registro de porción
- El usuario selecciona gramos con un slider (5–500g, paso de 5g).
- Presets rápidos: 50g, 100g, 150g, 200g.
- Muestra calorías calculadas en tiempo real según los gramos seleccionados.
- Al guardar, se persiste en SwiftData con el timestamp exacto.

### Lo que se elimina / no se muestra en el detalle básico
- La sección "Otros nutrientes" (fibra, azúcar, sodio) fue removida de la vista principal. Aparecerá dentro de "Saber más" en un evolutivo.

---

## 5. Registro diario

### Tab "Hoy"
- Resumen en la parte superior: calorías totales del día + barra de macros (P/C/G proporcional).
- Lista de todos los alimentos registrados hoy, del más reciente al más antiguo.
- Cada fila muestra: nombre, gramos, calorías calculadas.
- Estado vacío con mensaje motivador si no hay registros.

### Tab "Esta semana"
- Mini-gráfica de barras horizontales: un bar por día, altura proporcional a calorías.
- Lista de días con registros: nombre del día, fecha, total de calorías, cantidad de alimentos.
- Solo se muestran días con al menos un registro.
- Rango: últimos 7 días incluyendo hoy.

### Persistencia
- SwiftData local. Sin sincronización en la nube en el MVP.
- `LogEntryModel` almacena: nombre del alimento, fdcId, gramos, todos los nutrientes disponibles al momento del registro, timestamp.

---

## 6. Estadísticas

### Estructura de la pantalla
- **Dos tabs arriba:** `Hoy` y `Esta semana`
- Comportamiento: los datos de nutrientes cambian según el tab seleccionado (valores del día vs. promedio/acumulado de la semana).

### Sección 1 — Calorías
- **Gráfica de línea** que muestra calorías por día durante los últimos 7 días.
- **Línea de meta** horizontal que cruza la gráfica.
- La meta la define el usuario manualmente en su perfil o directamente en esta pantalla.
- **Validación de meta:**
  - Mínimo saludable: 1.200 kcal (advertencia si se intenta poner menos).
  - Máximo con advertencia: 4.000 kcal (se permite pero se muestra aviso).
  - No hay máximo bloqueante — el usuario es adulto y decide.

### Sección 2 — Nutrientes personalizados
- **El usuario elige qué nutrientes quiere monitorear.** No hay lista fija.
- Botón `+ Agregar nutriente` abre una búsqueda/lista de nutrientes disponibles.
- Nutrientes guardados = configuración persistente (SwiftData o UserDefaults).

**Por cada nutriente seleccionado, la tarjeta muestra:**

```
┌─────────────────────────────────┐
│ 🔴  Hierro                      │
│     8.2 mg / 18 mg              │
│     ████░░░░░░░░ 46%            │
│     "Por debajo del mínimo      │
│      recomendado"               │
└─────────────────────────────────┘
```

- **Semáforo de color:**
  - 🔴 Rojo: < 50% del valor diario recomendado
  - 🟡 Amarillo: 50–85% del VDR
  - 🟢 Verde: ≥ 85% del VDR
- **Valor real + meta:** `8.2 mg / 18 mg`
- **Barra de progreso** hacia la meta.
- **Mensaje corto** si está en rojo o amarillo.
- El VDR por defecto es para **persona adulta estándar** (sin sexo ni edad específicos).
- Si el usuario completa su perfil, se usan los valores personalizados.

### Valores diarios de referencia (VDR) por defecto

| Nutriente | VDR adulto estándar | Unidad |
|---|---|---|
| Hierro | 14 mg | mg |
| Magnesio | 375 mg | mg |
| Calcio | 1.000 mg | mg |
| Zinc | 10 mg | mg |
| Potasio | 3.500 mg | mg |
| Sodio | 2.300 mg | mg |
| Vitamina C | 80 mg | mg |
| Vitamina D | 15 µg | µg |
| Vitamina B12 | 2,4 µg | µg |
| Vitamina B6 | 1,4 mg | mg |
| Folato | 400 µg | µg |
| Vitamina A | 800 µg | µg |

> Fuente: Valores de referencia europeos (EFSA) como base estándar. Se ajustan si el usuario completa su perfil.

### Mensaje de personalización (banner no invasivo)
Cuando el usuario no tiene perfil completo, se muestra un banner sutil:
> *"¿Querés ver valores más precisos? Completa tu perfil."*
> → Botón que lleva directo al tab Perfil.

---

## 7. Perfil de usuario

### Filosofía
- **No es obligatorio.** La app funciona desde el día 1 sin perfil.
- **Mejora la experiencia progresivamente.** A más datos, más precisos los VDR en estadísticas.
- **Sin presión.** El banner de "completa tu perfil" es informativo, nunca bloqueante.

### Campos del perfil

| Campo | Tipo | Efecto en la app |
|---|---|---|
| Nombre | Texto libre | Personaliza el saludo en la pantalla de inicio |
| Sexo biológico | Selección (Femenino / Masculino / Prefiero no decir) | Ajusta VDR de hierro, folato, calcio |
| Año de nacimiento | Picker de año | Calcula edad → ajusta VDR de vitamina D, calcio |
| Peso | Número + unidad (kg/lb) | Referencia para meta calórica sugerida |
| Altura | Número + unidad (cm/ft) | Referencia para meta calórica sugerida |
| Nivel de actividad | Selector (Sedentario / Moderado / Activo / Muy activo) | Ajusta meta calórica sugerida |
| Meta calórica diaria | Número editable | Línea de meta en la gráfica de estadísticas |
| Condiciones de salud | Búsqueda + tags | Ajuste de VDR y advertencias en estadísticas |

### Condiciones de salud — diseño de tags
- El usuario escribe en un campo de búsqueda (ej. "anemia", "diabet", "embarazo").
- La búsqueda filtra una lista predefinida de condiciones.
- Al seleccionar, aparece como **tag removible**.
- Las condiciones afectan los VDR aplicados en estadísticas.

**Condiciones predefinidas en el MVP:**

| Condición | Efecto principal |
|---|---|
| Anemia | Sube VDR de hierro a 27 mg, resalta en rojo más fácilmente |
| Diabetes tipo 2 | Resalta azúcar y carbohidratos en estadísticas |
| Embarazo | Sube VDR de folato (600 µg), hierro (27 mg), calcio. Muestra advertencias |
| Hipertensión | Resalta sodio y potasio |
| Osteoporosis | Sube VDR de calcio y vitamina D |
| Hipotiroidismo | Resalta yodo y selenio (si están disponibles) |

### Persistencia del perfil
- SwiftData local. Un único `UserProfileModel` por dispositivo.
- Ningún dato sale del dispositivo en el MVP.

### Estado vacío (sin perfil)
- La pantalla de perfil muestra una invitación amigable a completar los datos.
- Copia: *"Cuéntanos un poco sobre ti para que Fooco pueda darte información más precisa."*
- No hay obstáculos para seguir usando la app sin llenar nada.

---

*Documento vivo — se actualiza con cada sesión de diseño.*
