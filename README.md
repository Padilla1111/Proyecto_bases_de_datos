# Proyecto BD: Análisis de Criminalidad en Chicago (Último Año)

## Integrantes
* **Luis Fernando Reyes Altamirano** - Clave Única: 214734 - [LuisRyes](https://github.com/LuisRyes)
* **Ismael Cabrera Arroyo** - Clave Única: 217632 - [mayelmais](https://github.com/mayelmais)
* **Rodrigo Flores Covarrubias** - Clave Única: 217893 - [covaconv](https://github.com/covaconv)
* **Juan Pablo Padilla** - Clave Única: 213650 - [Padilla1111](https://github.com/Padilla1111)
* **Martina Echeverría** - Clave Única: 214173 - [martinaecheverria](https://github.com/martinaecheverria)


## Introducción

Este proyecto analiza los incidentes criminales reportados en la ciudad de Chicago durante el período del 28 de abril de 2025 al 28 de abril de 2026. La información es recolectada por el **Chicago Police Department** mediante el sistema CLEAR (*Citizen Law Enforcement Analysis and Reporting*) y se publica a través del **Chicago Data Portal**.

* **Propósito de recolección:** Promover la transparencia, la rendición de cuentas institucional y facilitar el análisis de seguridad pública para la toma de decisiones.
* **Frecuencia de actualización:** Diaria.

## Objetivo del Proyecto

El objetivo principal es transformar un conjunto de datos plano de ~232,600 registros criminales en un **esquema relacional robusto normalizado hasta Cuarta Forma Normal (4FN)**, implementado en PostgreSQL. El proyecto demuestra todo el ciclo de ingeniería de datos:

1. **Carga (raw):** Importación íntegra del CSV original sin transformaciones
2. **Limpieza (cleaning):** Conversión de tipos, deduplicación temporal, estandarización de texto y tratamiento de valores nulos
3. **Normalización (normalization):** Descomposición en 6 relvars en 4FN, derivadas completamente del schema cleaning sin dependencias de archivos externos
4. **Análisis avanzado:** Consultas SQL con funciones de ventana (`RANK()`, `LAG()`) para identificar patrones temporales, tasas de arresto y variaciones geográficas

**Preguntas clave respondidas:**
- ¿En qué meses del año se concentra la criminalidad y cómo varía la efectividad policial (tasa de arresto)?
- ¿Qué tipos de crimen tienen mayor tasa de resolución (arresto)?
- ¿Cómo evoluciona el volumen de criminalidad mes a mes por zona geográfica (ward)?
- ¿En qué franjas horarias ocurren más delitos y con qué eficacia se responde?

### Descripción Técnica de Atributos (Dataset Original)

Para la fase `raw`, se respeta la estructura del archivo fuente. La siguiente tabla describe los 17 atributos originales:

| Atributo | Tipo | Descripción |
| :--- | :--- | :--- |
| **Case Number** | Texto | Identificador único del caso (PK natural) |
| **Date of Occurrence** | Timestamp | Fecha y hora exacta del incidente |
| **Block** | Texto | Dirección anonimizada a nivel de cuadra |
| **IUCR** | Texto | Illinois Uniform Crime Reporting code (410 valores únicos) |
| **Primary Description** | Texto | Categoría principal del delito (31 valores únicos) |
| **Secondary Description** | Texto | Detalle o subcategoría del delito |
| **Location Description** | Texto | Tipo de lugar (calle, residencia, etc. — 131 valores únicos) |
| **Arrest** | Booleano | Si resultó en arresto (Y/N) |
| **Domestic** | Booleano | Si fue violencia doméstica (Y/N) |
| **Beat** | Entero | Unidad de patrullaje más pequeña (274 valores únicos) |
| **Ward** | Entero | Distrito electoral/concejalía (50 valores únicos) |
| **FBI CD** | Texto | Código de clasificación FBI (26 valores únicos) |
| **X Coordinate** | Numérico | Proyección Illinois State Plane (redundante) |
| **Y Coordinate** | Numérico | Proyección Illinois State Plane (redundante) |
| **Latitude** | Numérico | Coordenada geográfica exacta |
| **Longitude** | Numérico | Coordenada geográfica exacta |
| **Location** | Texto | Tupla "(lat, lon)" — redundante con Latitude/Longitude |

> **Nota sobre redundancia:** Las columnas `LOCATION`, `X COORDINATE` y `Y COORDINATE` son eliminadas en la fase de limpieza por redundancia. `X COORDINATE` y `Y COORDINATE` usan una proyección diferente (Illinois State Plane) vs. Latitude/Longitude (WGS84), y se conservan Latitude/Longitude por ser el estándar analítico.

### Consideraciones Éticas

El análisis de datos de criminalidad conlleva responsabilidad ética significativa:

* **Privacidad y Anonimato:** Los datos se respetan a nivel de cuadra. No se intenta reidentificación de víctimas o individuos.
* **Reconocimiento de Sesgos:** Los datos representan *crímenes reportados*, no el universo real de delitos. Reflejan sesgos de vigilancia policial, disponibilidad de denunciantes y capacidad institucional.
* **Prevención de Estigmatización:** El análisis geográfico (por ward) se presenta sin prejuicios, reconociendo que factores socioeconómicos subyacentes explican variaciones, no determinaciones de seguridad intrínseca.
* **Responsabilidad en el Uso:** Aunque los datos son públicos (*open data*), su análisis requiere contexto social. Este proyecto es técnico y estructural, no prescriptivo sobre políticas públicas.

## Fuente de Datos

Se utilizan datos del **Chicago Data Portal**, dataset: *"Crimes - One Year Prior to Present"*  
Link: https://data.cityofchicago.org/Public-Safety/Crimes-One-year-prior-to-present/x2n5-8w5q

**Para este proyecto:**
- Período: 28 de abril de 2025 — 28 de abril de 2026
- Registros totales: ~232,600 (muestra de trabajo: 232,593 después de limpieza)
- Requisito cumplido: >5,000 tuplas

###  Configuración para Replicación

1. Crea una carpeta `data/` en la raíz del proyecto
2. Descarga `raw_data.csv` desde el Chicago Data Portal
3. Guarda el archivo como `data/raw_data.csv`
4. El `.gitignore` ya excluye este archivo (>200 MB)
5. Ejecuta los scripts en orden: 01 → 02 → 03

```bash
# Desde la raíz del proyecto:
psql -U tuUsuario -d crimenes -f pipeline_scripts/01_raw_data_schema_creation_and_load.sql
psql -U tuUsuario -d crimenes -f pipeline_scripts/02_data_cleaning.sql
psql -U tuUsuario -d crimenes -f pipeline_scripts/03_data_normalization.sql
psql -U tuUsuario -d crimenes -f exploration_queries/02_analytical_queries.sql
```

## Estructura del Repositorio

```
├── README.md                                    ← Documentación técnica
├── data/
│   ├── .gitignore                              ← Excluye raw_data.csv (~200 MB)
│   └── raw_data.csv                            ← Usuario descarga de Chicago Portal
│
├── pipeline_scripts/                           ← Pipeline de datos (3 fases)
│   ├── 01_raw_data_schema_creation_and_load.sql   ← Fase Raw: carga íntegra CSV
│   ├── 02_data_cleaning.sql                       ← Fase Cleaning: limpieza + dedup
│   └── 03_data_normalization.sql                  ← Fase Normalization: 4FN
│
└── exploration_queries/                        ← Queries analíticas
    ├── 01_raw_data_exploration.sql             ← EDA preliminar (soporte fase Raw)
    └── 02_analytical_queries.sql               ← 4 consultas avanzadas con window functions
```

---

# Procesamiento de Datos

## Actividad B: Carga Inicial (`raw` schema)

**Objetivo:** Importación íntegra del CSV sin transformaciones, preservando tipos de texto.

**Ejecución:**
```bash
psql -U tuUsuario -d crimenes -f pipeline_scripts/01_raw_data_schema_creation_and_load.sql
```

**Resultado:**
- Tabla: `raw.chicago_crimes` (17 columnas, todos TEXT)
- Registros cargados: 232,615 (incluye duplicados por actualización de expedientes)
- Estructura sin conversión de tipos ni limpieza

---

## Actividad C: Limpieza (`cleaning` schema)

**Objetivo:** Conversión de tipos, deduplicación, tratamiento de nulos, estandarización de texto.

### 1. Estrategia de Deduplicación

**Hallazgo:** 18 case_numbers tenían múltiples registros con fechas diferentes → actualización de expedientes policiales.

**Solución:** Usar ventana temporal — mantener solo el registro más reciente por case_number:
```sql
ROW_NUMBER() OVER(
    PARTITION BY case_number 
    ORDER BY date_occurrence DESC
) = 1
```

**Resultado:** 232,593 registros únicos (reducción de 22 duplicados históricos)

### 2. Transformaciones Realizadas

| Columna | Raw | Cleaning | Lógica |
| :--- | :--- | :--- | :--- |
| `date_occurrence` | TEXT | TIMESTAMP | Formato: `MM/DD/YYYY HH12:MI:SS AM` |
| `arrest`, `domestic` | TEXT (Y/N) | BOOLEAN | Y → TRUE, N → FALSE, vacío → NULL |
| `beat`, `ward` | TEXT | INTEGER | Valores numéricos con NULLIF para vacíos |
| `x_coordinate`, `y_coordinate` | TEXT | DOUBLE PRECISION | Casting con NULLIF |
| `latitude`, `longitude` | TEXT | DOUBLE PRECISION | Casting con NULLIF |
| `primary_description`, `block` | TEXT | VARCHAR | TRIM + UPPER para consistencia |
| `location_description` | TEXT | VARCHAR | TRIM + consolidación STREET/SIDEWALK |

**Columnas eliminadas:**
- `location` (tupla "(lat, lon)" — redundante)
- `x_coordinate`, `y_coordinate` (proyección Illinois State Plane — redundante con lat/lon WGS84)

### 3. Técnicas Avanzadas de Limpieza

* **Tratamiento de nulos:** `NULLIF(TRIM(columna), '')` para strings vacíos
* **Fuzzy matching:** Extensión `fuzzystrmatch` (distancia Levenshtein) para corregir typos delictivos
* **Consolidación de categorías:** Variantes de STREET/SIDEWALK agrupadas; ubicaciones raras (<5 registros) → "OTHER (LOW FREQUENCY)"
* **Imputación de FBI_CD faltantes:** Usar mapeo IUCR → FBI_CD del mismo dataset

**Resultado:** Tabla `cleaning.chicago_crimes` (14 columnas, tipos nativos)

**Ejecución:**
```bash
psql -U postgres -d crimenes -f pipeline_scripts/02_data_cleaning.sql
```

---

## Actividad D: Normalización a 4FN (`normalization` schema)

**Objetivo:** Descomponer en relvars que eliminen todas las dependencias transitivas y derivadas completamente del schema `cleaning`.

### 1. Análisis de Dependencias Funcionales

| FD | Violación | Solución |
| :--- | :--- | :--- |
| `case_number → {todos}` | Clave candidata (1NF) | PK en tabla incident |
| `iucr → primary_desc, secondary_desc` | Repetición en ~232k registros | Tabla iucr separada (2NF) |
| `iucr → fbi_cd` | Transitiva: case → iucr → fbi_cd | Tabla iucr aislada (BCNF) |
| `fbi_cd → description` | Si tuviéramos descriptions, violaría BCNF | Modelada sin atributos extra (simplificación) |
| `beat → district_id` | Relación jerárquica | Simplificación: tabla beat sin FK a district |
| `location_type_id → location_description` | 1:1 | Tabla location_type separada |

### 2. Relvars Resultantes (6 tablas)

```sql
-- Catálogos (derivados 100% de cleaning con SELECT DISTINCT)
normalization.beat            (beat_id SERIAL PK, beat VARCHAR UNIQUE)
normalization.ward            (ward_id SMALLINT PK)
normalization.fbi_code        (fbi_cd VARCHAR(10) PK)
normalization.iucr            (iucr_id SERIAL PK, iucr VARCHAR UNIQUE, 
                               primary_description, secondary_description, fbi_cd FK)
normalization.location_type   (location_type_id SERIAL PK, location_description VARCHAR UNIQUE)

-- Tabla de hechos
normalization.incident        (incident_id SERIAL PK, case_number VARCHAR UNIQUE,
                               date_occurrence TIMESTAMP, arrest BOOLEAN, domestic BOOLEAN,
                               beat_id FK, ward_id FK, iucr_id FK, location_type_id FK)
```

### 3. Decisiones de Diseño

1. **Simplificación deliberada:** Se eliminó la tabla `district` para que el diseño sea 100% autocontenido sin archivos externos. Los beats se modelan como catálogo simple (sin FK a district).

2. **Atributos simplificados:** Las tablas `ward` y `fbi_code` contienen solo la clave natural, sin atributos descriptivos que no están en los datos crudos. Esto garantiza reproducibilidad sin dependencias externas.

3. **Derivación del cleaning:** Todos los catálogos se poblan con:
   ```sql
   INSERT INTO normalization.TABLA SELECT DISTINCT ... FROM cleaning.chicago_crimes
   ```
   No se usan archivos CSV externos. Garantiza consistencia: los datos que se normalizan son exactamente lo que se limpió.

4. **Llaves surrogadas:** Todas las tablas usan SERIAL para PK, preservando claves naturales como UNIQUE constraints.

5. **Índices post-carga:** Se crean 6 índices en las columnas de mayor uso analítico (`beat_id`, `ward_id`, `iucr_id`, `date_occurrence`, `arrest`) al final para optimizar sin ralentizar inserts masivos.

**Ejecución:**
```bash
psql -U tuUsuario -d crimenes -f pipeline_scripts/03_data_normalization.sql
```

**Verificación de integridad:**
```sql
SELECT 'normalization.beat' AS tabla, COUNT(*) FROM normalization.beat
UNION ALL SELECT 'normalization.ward', COUNT(*) FROM normalization.ward
UNION ALL SELECT 'normalization.fbi_code', COUNT(*) FROM normalization.fbi_code
UNION ALL SELECT 'normalization.iucr', COUNT(*) FROM normalization.iucr
UNION ALL SELECT 'normalization.location_type', COUNT(*) FROM normalization.location_type
UNION ALL SELECT 'normalization.incident', COUNT(*) FROM normalization.incident;
```

**Resultados esperados:**
- beat: 274
- ward: 50
- fbi_code: 26
- iucr: 333
- location_type: 107
- incident: 232,593

---

# Análisis Avanzado (Actividad E)

## Consultas Analíticas con Window Functions

**Archivo:** `exploration_queries/02_analytical_queries.sql`

Todas las consultas se ejecutan sobre `normalization.*` y usan funciones de ventana SQL avanzadas para análisis temporal y rankings.

### Query 1: Tendencia Mensual de Criminalidad

**Pregunta:** ¿En qué meses del año ocurren más crímenes y varía la tasa de arresto estacionalmente?

**Función de ventana:** `RANK() OVER (ORDER BY COUNT(*) DESC)` — ranking de volumen por mes

**Hallazgos principales:**
- **Pico:** Julio (22,643 incidentes, 1er lugar) seguido de Agosto (21,317) y Junio (21,102)
- **Valle:** Febrero (16,358) y Enero (16,822)
- **Variación estacional:** ~38% más crímenes en verano vs. invierno
- **Tasa de arresto:** ~15-16% consistente todos los meses — **sin estacionalidad en efectividad policial**

**Implicación:** El aumento de delitos es real, no correlacionado con cambios en capacidad de arresto.

### Query 2: Tasa de Arresto por Tipo de Crimen

**Pregunta:** ¿Qué tipos de crimen tienen mayor tasa de resolución y cuáles son los más tolerados?

**Función de ventana:** `RANK() OVER (ORDER BY arrest_rate_pct DESC)` — ranking de tasa de arresto

**Hallazgos principales:**

| Rango | Delito | Tasa Arresto | Volumen | Interpretación |
| :--- | :--- | :--- | :--- | :--- |
| 1 | Concealed Carry License Violation | 97.3% | 220 | Violaciones de permisos — casi todas resultan en arresto |
| 2 | Narcotics | 94.0% | 6,717 | Infracciones de drogas — ejecución fuerte (volumen alto) |
| 14 | Robbery | 9.3% | 5,365 | Hurtos a mano armada — baja resolución (5,365 delitos, solo 499 arrestos) |
| 15 | Theft | 8.8% | 53,079 | **Mayor volumen del dataset — pero baja tasa de arresto** |
| 24 | Intimidation | 0.56% | 180 | Amenazas/intimidación — casi nunca se arrests (1/180) |

**Insight crítico:** Los delitos de alto volumen (Theft, Assault, Battery) tienen tasas de arresto <20%, mientras que delitos menores regulatorios (Narcotics, Weapons) alcanzan 70-95%. Sugiere enfoque policial en ejecución de delitos específicos.

### Query 3: Variación Mes a Mes por Ward

**Pregunta:** ¿Cómo evolucionó el volumen de criminalidad por zona geográfica (ward) mes a mes?

**Función de ventana:** `LAG() OVER (PARTITION BY ward_id ORDER BY month)` — comparar cada ward consigo mismo en tiempo

**Lógica:**
```sql
month_over_month_delta = total_incidents - LAG(total_incidents) OVER (...)
```

**Hallazgos principales:**

| Ward | Volatilidad | Patrón |
| :--- | :--- | :--- |
| Ward 27 | Muy alta | Picos 1,000+ incidentes (Jul-Oct), caídas a 600+ (Feb). ΔMax = +914 (abr→may), ΔMin = -246 (abr) |
| Ward 6 | Alta | ~600-900 incidentes/mes. Drop abrupto Nov (-83). Recovery Mar (+97) |
| Ward 42 | Alta | 800+ incidentes/mes hasta Nov (-188 drop). Recuperación lenta (Feb +2, Mar +157) |
| Ward 50 | Baja | ~150-240 incidentes/mes. Variación ±60 — más estable |

**Insight:** Algunos wards muestran caídas drásticas en Nov-Dic (posible cambio de patrullaje, eventos especiales o reportería reducida en vacaciones), con recuperación variable en 2026.

### Query 4: Distribución por Franja Horaria

**Pregunta:** ¿En qué franjas horarias ocurren más delitos y cómo varía la efectividad policial?

**Cálculos:**
- `arrest_rate_pct` — tasa de arresto por franja
- `pct_of_total` — porcentaje del total de incidentes

**Hallazgos principales:**

| Franja | Incidentes | % del Total | Tasa Arresto |
| :--- | :--- | :--- | :--- |
| **Tarde** (12-17h) | 73,033 | 31.4% | 15.6% |
| **Noche** (18-23h) | 65,325 | 28.1% | 18.2% |
| **Mañana** (6-11h) | 49,088 | 21.1% | 13.6% |
| **Madrugada** (0-5h) | 45,147 | 19.4% | 12.4% |

**Insight:** La Tarde es el período de mayor riesgo (31% de crímenes), pero la Noche tiene **mayor tasa de arresto (18.2% vs 15.6%)**. Sugiere respuesta más efectiva durante horas de mayor vigilancia (noche), aunque el volumen total es menor.

---

## Ejecución de Queries

```bash
psql -U tuUsuario -d crimenes -f exploration_queries/02_analytical_queries.sql
```

Salida esperada: 4 tablas con resultados analíticos listos para visualización/reporte.

---

# Resumen de Resultados

| Métrica | Valor |
| :--- | :--- |
| Registros raw cargados | 232,615 |
| Registros después de dedup | 232,593 |
| Relvars en 4FN | 6 |
| Catálogos únicos (beats, wards, IUCRs, FBI codes) | 274 + 50 + 333 + 26 = 683 |
| Consultas analíticas ejecutadas | 4 (con window functions) |
| Tasa de arresto global | 15.5% (36,071 / 232,593) |
| Mayor volumen de delito | Theft (53,079 incidentes, 22.8% del total) |
| Mes de mayor criminalidad | Julio (22,643 incidentes) |
| Franja horaria de riesgo máximo | Tarde 12-17h (31.4% del total) |

---

# Notas Técnicas

## Reproducibilidad

El pipeline es 100% reproducible y autocontenido:
- Solo requiere `raw_data.csv` (descargable del Chicago Data Portal)
- Todos los catálogos se derivan del cleaning con `SELECT DISTINCT`
- Sin archivos externos, sin hardcoding
- Scripts idempotentes (refresh destructivo, DROP CASCADE)

## Limitaciones Éticas Reconocidas

1. Los datos representan *delitos reportados* → sesgo de reportería y vigilancia policial
2. Concentración geográfica (Ward 27, 6, 42 con 700-1000 incidentes/mes) puede reflejar:
   - Mayor densidad de población/actividad
   - Distribución desigual de recursos policiales
   - Factores socioeconómicos subyacentes
3. No se debe usar para "criminalizar" zonas sin contexto social

## Performance

Índices creados:
- `idx_incident_beat` en `beat_id` 
- `idx_incident_ward` en `ward_id`
- `idx_incident_iucr` en `iucr_id`
- `idx_incident_loc_type` en `location_type_id`
- `idx_incident_date` en `date_occurrence`
- `idx_incident_arrest` en `arrest` (para filtros de tasa de arresto)
