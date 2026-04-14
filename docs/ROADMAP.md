# Fooco — Roadmap

**Versión:** 0.3  
**Última actualización:** 2026-04-10  

> Qué está hecho, qué viene ahora, y qué se queda para después.  
> Los "evolutivos" son decisiones conscientes de dejar para más adelante — no deuda técnica, sino priorización.

---

## ✅ Hecho (MVP actual)

### Búsqueda
- [x] Búsqueda de alimentos contra USDA FoodData Central
- [x] Traducción automática de query (español → inglés)
- [x] Traducción de nombres de alimentos al idioma del dispositivo
- [x] Paginación: 10 resultados por página con scroll infinito
- [x] Alimentos frecuentes en la pantalla de inicio de búsqueda

### Detalle de alimento
- [x] Macros desde búsqueda (sin llamada extra al abrir)
- [x] Sección "Saber más" con carga bajo demanda (endpoint `/food/{fdcId}`)
- [x] Porciones de referencia (cucharada, taza, etc.)
- [x] Minerales, vitaminas, desglose de grasas en "Saber más"
- [x] Selector de gramos con slider y presets
- [x] Cálculo de calorías en tiempo real

### Registro
- [x] Guardar alimento con gramos y timestamp (SwiftData)
- [x] Vista de registros del día (tab "Hoy")
- [x] Vista de historial semanal (tab "Esta semana")
- [x] Mini-gráfica de barras por día de la semana

### Infraestructura
- [x] Clean Architecture (Domain → Data → Presentation)
- [x] SwiftData con `@ModelActor` para persistencia local
- [x] Traducciones: español latinoamericano, inglés, portugués
- [x] Tests unitarios >80% cobertura en Domain y Data

---

## 🔨 En construcción (siguiente sprint)

### Perfil de usuario
- [ ] Pantalla de perfil con datos básicos (nombre, sexo, edad, peso, altura)
- [ ] Nivel de actividad
- [ ] Meta calórica diaria (con validación de rango saludable)
- [ ] Condiciones de salud como tags (búsqueda + selección)
- [ ] Condiciones predefinidas: anemia, diabetes, embarazo, hipertensión, osteoporosis
- [ ] Persistencia con SwiftData (`UserProfileModel`)
- [ ] Banner no invasivo en estadísticas cuando no hay perfil

### Estadísticas
- [ ] Tabs "Hoy" / "Esta semana"
- [ ] Gráfica de línea de calorías (7 días)
- [ ] Línea de meta calórica en la gráfica
- [ ] Sección de nutrientes personalizados
- [ ] Botón `+ Agregar nutriente` con búsqueda
- [ ] Tarjeta de nutriente: valor real, barra de progreso, semáforo, mensaje corto
- [ ] VDR por defecto para adulto estándar
- [ ] VDR ajustados por perfil (sexo, edad, condiciones)
- [ ] Persistencia de nutrientes seleccionados

---

## 📋 Backlog (definido pero no priorizado)

### Perfil — evolutivos
- [ ] Encuesta de onboarding al primer uso
  - Motivación: recopilar datos para análisis (con consentimiento)
  - Preguntas: objetivo (bajar/subir/mantener), condiciones, nivel de actividad
- [ ] Foto de perfil
- [ ] Unidades personalizables (lb/kg, ft/cm)

### Estadísticas — evolutivos
- [ ] "Saber más" por nutriente: qué es, para qué sirve, alimentos ricos en ese nutriente
  - Sería un modal / sheet con información educativa
  - Listar alimentos de la base USDA ricos en ese nutriente → link a búsqueda
- [ ] Tendencia a largo plazo (mes, 3 meses)
- [ ] Comparación semana vs. semana anterior
- [ ] Exportar datos (CSV, PDF)

### Detalle de alimento — evolutivos
- [ ] Fibra, azúcar y sodio en "Saber más" (actualmente removidos del detalle básico)
- [ ] Advertencias contextuales por condición de salud
  - Ej: si el usuario tiene diabetes → resaltar azúcar en rojo en el detalle
  - Ej: si tiene embarazo → warning en alimentos con alto mercurio o listeria risk

### Registro — evolutivos
- [ ] Eliminar un registro del historial (swipe to delete)
- [ ] Editar gramos de un registro ya guardado
- [ ] Comidas del día organizadas por momento (desayuno, almuerzo, cena, snack)
- [ ] Foto del plato (estimación de porción por visión)

### Alimentos propios — evolutivos
- [ ] El usuario puede crear su propio alimento
  - Nombre, calorías, macros manuales
  - Útil para comidas típicas latinoamericanas no indexadas en USDA
- [ ] Recetas: combinar varios alimentos en una entrada

### Social / datos — evolutivos
- [ ] Sincronización en la nube (iCloud o backend propio)
- [ ] Exportar datos de forma anónima para análisis (opt-in)
- [ ] Análisis de patrones de consumo (data analytics)

### Técnica
- [ ] Widget de iOS (calorías del día en la pantalla de inicio)
- [ ] Notificaciones opcionales (recordatorio de registrar)
- [ ] Apple Health integration (leer peso, escribir calorías)
- [ ] Soporte iPad (NavigationSplitView)

---

## 🚫 Fuera de scope (decisiones explícitas)

| Feature | Razón |
|---|---|
| Escáner de código de barras | Enfoque en alimentos frescos y sin procesar primero |
| Contador de pasos / ejercicio | No es una app de fitness, es de alimentación |
| Recomendaciones de IA | Requiere perfil completo y datos suficientes; evolutivo |
| Comunidad / social feed | Fuera del core value del MVP |
| Suscripción / monetización | A definir cuando haya base de usuarios |

---

*Documento vivo — se revisa al inicio de cada sprint.*
