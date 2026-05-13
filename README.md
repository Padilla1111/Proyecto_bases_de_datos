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
4. **Análisis avanzado:** Diez consultas en `exploration_queries/02_analytical_queries.sql` (varias con `RANK()`, `LAG()` y otras ventanas) exportadas a CSV; la mayoría operan sobre `normalization`, tres sobre `raw` (ver Actividad E).

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
| **IUCR** | Texto | Illinois Uniform Crime Reporting code (cardinalidad depende del corte temporal del CSV; en el EDA del raw documentado: 332 códigos distintos) |
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

> **Nota sobre redundancia:** En limpieza solo se elimina la columna compuesta `location` (redundante con latitud y longitud). Las columnas `x_coordinate` y `y_coordinate` (Illinois State Plane) se **conservan** en `cleaning` junto con `latitude` y `longitude` (WGS84); en normalización pasan a `normalization.incident` con el tipado definido en el script `03`.

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
- Período: 28 de abril de 2025 — 28 de abril de 2026 (link de descarga de los datos en esta ventana de tiempo [aquí](https://drive.google.com/drive/folders/10-k0SMeGqK_xzf3rYdQ1Y15gDT14BL4y?usp=sharing))
- Registros totales: ~232,600 (muestra de trabajo: 232,593 después de limpieza)
- Requisito cumplido: >5,000 tuplas

###  Configuración para Replicación

1. Clonar el repositorio:

```bash
git clone https://github.com/Padilla1111/Proyecto_bases_de_datos.git
cd Proyecto_bases_de_datos
```

2. Crea una carpeta `data/` en la raíz del proyecto (si no existe).
3. Descarga `raw_data.csv` desde el drive enlazado arriba.
4. Guarda el archivo como `data/raw_data.csv`.
5. El archivo bajo `data/` queda fuera de Git por la regla `data/*` en el `.gitignore` de la raíz (no uses un `.gitignore` separado dentro de `data/`).
6. **PostgreSQL:** el script `02_data_cleaning.sql` ejecuta `CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;`. Se requiere un rol con permiso para crear extensiones (habitualmente superusuario) o que un administrador instale `fuzzystrmatch` de antemano.
7. Asegura la carpeta `results_csv/` en la raíz (en el repositorio ya viene incluida; si la borras, créala de nuevo antes de las analíticas). El script `exploration_queries/02_analytical_queries.sql` escribe ahí archivos CSV mediante `\o`.
8. Ejecuta los scripts **con el directorio de trabajo actual = raíz del repositorio** (obligatorio: `01_raw_data_schema_creation_and_load.sql` usa `\COPY ... FROM './data/raw_data.csv'`, y las rutas `\o` de las analíticas son relativas a ese mismo directorio).

```bash
# PowerShell / bash: primero cd a la raíz del clon, luego:
psql -U tuUsuario -d crimenes -f pipeline_scripts/01_raw_data_schema_creation_and_load.sql
psql -U tuUsuario -d crimenes -f pipeline_scripts/02_data_cleaning.sql
psql -U tuUsuario -d crimenes -f pipeline_scripts/03_data_normalization.sql
psql -U tuUsuario -d crimenes -f exploration_queries/02_analytical_queries.sql
```

## Estructura del Repositorio

```
├── README.md
├── .gitignore                    ← Excluye contenido de data/ (p. ej. raw_data.csv)
├── index.html                    ← Punto de entrada opcional en raíz
├── data/                         ← raw_data.csv (local; no versionado)
├── pipeline_scripts/
│   ├── 01_raw_data_schema_creation_and_load.sql
│   ├── 02_data_cleaning.sql
│   └── 03_data_normalization.sql
├── exploration_queries/
│   ├── 01_raw_data_exploration.sql
│   └── 02_analytical_queries.sql   ← 10 consultas → CSV en results_csv/
├── results_csv/                  ← Salida de 02_analytical_queries.sql (\o)
└── visualizations/
    └── index.html
```

### Dashboard interactivo

El repositorio incluye una interfaz web estática en la raíz ([`index.html`](index.html)) construida con **React 18** y **Recharts**. Los gráficos y tablas reflejan los mismos hallazgos que exportan los CSV en [`results_csv/`](results_csv/), incluidas todas las consultas. 

Para facilitar el acceso, el dashboard ha sido publicado con **GitHub Pages** desde la rama `main`. Puedes visualizarlo en este URL: [https://padilla1111.github.io/Proyecto_bases_de_datos/](https://padilla1111.github.io/Proyecto_bases_de_datos/).

---

# Procesamiento de Datos

## Actividad B: Carga inicial y análisis preliminar (`raw` schema)

**Objetivo:** Importación íntegra del CSV sin transformaciones, preservando tipos de texto.

**Ejecución (desde la raíz del repositorio):**
```bash
psql -U tuUsuario -d crimenes -f pipeline_scripts/01_raw_data_schema_creation_and_load.sql
```

**Resultado:**
- Tabla: `raw.chicago_crimes` (17 columnas, todos TEXT)
- Registros cargados: 232,615 (incluye duplicados por actualización de expedientes)
- Estructura sin conversión de tipos ni limpieza

---
## Análisis preliminar

### Ejecución del proceso
Para ejecutar el análisis preliminar, asegúrate de estar en la **raíz del proyecto** y ejecuta:

```bash
psql -U tuUsuario -d crimenes -f exploration_queries/01_raw_data_exploration.sql
```

## Descripción de Columnas y Valores Únicos

Total de tuplas en la tabla: **232,588** (conteo sobre el snapshot de `raw_data.csv` usado en el EDA documentado; una descarga distinta del portal puede variar ligeramente respecto a las cifras de carga en Actividad B).

| Columna | Valores Únicos | Descripción |
|---|---|---|
| `case_number` | 232,565 | 23 menos que el total de tuplas, lo que indica la presencia de duplicados. Es candidata a llave primaria una vez que se realice la limpieza de duplicados. |
| `date_occurrence` | 120,828 | Representa fecha y hora exacta del incidente en formato `MM/DD/YYYY HH:MI:SS AM/PM`. La alta cardinalidad es esperada. Sugiere tipo de dato `TIMESTAMP`. |
| `block` | 27,971 | Partición geográfica a nivel calle dentro de Chicago. Variable categórica de alta cardinalidad. |
| `iucr` | 332 | Código categórico del Illinois Uniform Crime Reporting. Clasifica el tipo de crimen. |
| `primary_description` | 31 | Categoría principal del crimen. Baja cardinalidad confirma que es una variable categórica con valores predefinidos. |
| `secondary_description` | 310 | Subcategoría del crimen, complementa a `primary_description` con mayor detalle. |
| `location_description` | 131 | Tipo de lugar donde ocurrió el crimen (calle, residencia, etc.). Variable categórica predefinida. |
| `fbi_cd` | 26 | Código categórico del FBI que clasifica el crimen según estándares federales. |
| `arrest` | 2 | Variable booleana que indica si hubo arresto. |
| `domestic` | 2 | Variable booleana que indica si el crimen fue de violencia doméstica. |
| `beat` | 274 | Unidad de patrullaje policial en Chicago. Variable categórica que representa la partición geográfica más pequeña. |
| `ward` | 51 | Distrito político-administrativo de Chicago. Variable categórica con 50 distritos oficiales más un posible valor nulo o especial. |
| `x_coordinate` | 48,869 | Coordenada X en el sistema de coordenadas proyectadas estatal de Illinois (ILCS). Tipo de dato `FLOAT`. |
| `y_coordinate` | 67,348 | Coordenada Y en el sistema de coordenadas proyectadas estatal de Illinois (ILCS). Tipo de dato `FLOAT`. |
| `latitude` | 112,597 | Coordenada geográfica en el sistema WGS84. Alta cardinalidad esperada dado que representa posiciones precisas. Tipo de dato `FLOAT`. |
| `longitude` | 112,596 | Coordenada geográfica en el sistema WGS84. Alta cardinalidad esperada dado que representa posiciones precisas. Tipo de dato `FLOAT`. |
| `location` | 112,624 | Campo compuesto que combina latitud y longitud en formato `(lat, long)`. Redundante con las columnas `latitude` y `longitude`. |


## Rango Temporal

El campo `date_occurrence` está almacenado originalmente en formato `MM/DD/YYYY HH:MI:SS AM/PM`. Al convertirlo a `TIMESTAMP` mediante `TO_TIMESTAMP`, Postgres lo representa en formato `YYYY-MM-DD HH:MM:SS`. El dataset cubre exactamente un año de registros:

| | Valor |
|---|---|
| Fecha mínima | 2025-04-29 05:02:00 |
| Fecha máxima | 2026-04-28 00:00:00 |

## Rango Geográfico

Se verificó que los rangos de latitud y longitud son consistentes con la ubicación geográfica de Chicago. Los 113 registros con coordenadas vacías fueron excluidos de este cálculo.

| | Mínimo | Máximo |
|---|---|---|
| `latitude` | 41.644608279 | 42.022547568 |
| `longitude` | -87.928903079 | -87.524529378 |

## Conteo de Valores Nulos y Vacíos

No se encontraron valores `NULL` en ninguna columna del dataset. Sin embargo, se identificaron valores vacíos (`''`) que funcionalmente equivalen a nulos:

| Columna | Valores Vacíos |
|---|---|
| `location_description` | 1,133 |
| `x_coordinate` | 113 |
| `y_coordinate` | 113 |
| `latitude` | 113 |
| `longitude` | 113 |
| `location` | 113 |
| `ward` | 1 |

Los 113 registros sin coordenadas son consistentes entre sí — cuando falta una coordenada, todas las columnas geográficas quedan vacías. Estos valores vacíos serán convertidos a `NULL` durante la limpieza para mantener consistencia en el esquema.

## Duplicados

### Duplicados en `case_number`

Se encontraron 18 números de caso repetidos en el dataset, algunos apareciendo hasta 4 veces. Al revisar todos los registros duplicados en detalle, se observaron dos patrones importantes:

1. **Todos los duplicados corresponden a homicidios** (`iucr = 0110`, `primary_description = HOMICIDE, FIRST DEGREE MURDER`), lo que sugiere que el sistema de registro policial aplica este comportamiento de actualización específicamente para casos de homicidio.

2. **La única columna que difiere entre los duplicados es `date_occurrence`**, donde las horas registradas son cercanas entre sí pero distintas. Por ejemplo, el caso `JJ309322` aparece 4 veces con horas de 2:50 AM, 2:55 AM, 3:29 AM y 10:10 AM. Todas las demás columnas son idénticas.

Esto confirma que los duplicados no representan crímenes distintos, sino **actualizaciones progresivas del mismo registro**, donde la hora del incidente fue refinada conforme avanzaba la investigación policial. El sistema optó por agregar un nuevo registro en lugar de sobreescribir el existente, generando así un historial de cambios.

### Filas completamente idénticas

De los 18 casos duplicados, 2 (`JJ460760` y `JK173315`) son filas completamente idénticas en todos sus atributos, incluyendo `date_occurrence`. Estos representan errores de carga y deben eliminarse.

### Estrategia de limpieza

Dado que el registro más reciente representa la versión más actualizada y precisa del incidente, la estrategia de limpieza será **conservar únicamente el último registro por `case_number`**, ordenando por `date_occurrence` de forma descendente. Esto aplica tanto para los duplicados con horas distintas como para las filas completamente idénticas.

## Valores de Atributos Categóricos

Los strings vacíos (`''`) identificados en la sección anterior son omitidos de este análisis, ya que serán tratados en la etapa de limpieza.

| Columna | Valores Distintos |
|---|---|
| `arrest` | `Y`, `N` |
| `domestic` | `Y`, `N` |
| `primary_description` | `ARSON`, `ASSAULT`, `BATTERY`, `BURGLARY`, `CONCEALED CARRY LICENSE VIOLATION`, `CRIMINAL DAMAGE`, `CRIMINAL SEXUAL ASSAULT`, `CRIMINAL TRESPASS`, `DECEPTIVE PRACTICE`, `GAMBLING`, `HOMICIDE`, `HUMAN TRAFFICKING`, `INTERFERENCE WITH PUBLIC OFFICER`, `INTIMIDATION`, `KIDNAPPING`, `LIQUOR LAW VIOLATION`, `MOTOR VEHICLE THEFT`, `NARCOTICS`, `NON-CRIMINAL`, `OBSCENITY`, `OFFENSE INVOLVING CHILDREN`, `OTHER NARCOTIC VIOLATION`, `OTHER OFFENSE`, `PROSTITUTION`, `PUBLIC INDECENCY`, `PUBLIC PEACE VIOLATION`, `ROBBERY`, `SEX OFFENSE`, `STALKING`, `THEFT`, `WEAPONS VIOLATION` |
| `secondary_description` | 310 valores que representan subcategorías específicas del crimen. Se agrupan en grandes familias temáticas: **agravantes** (`AGGRAVATED`, `AGGRAVATED - HANDGUN`, `AGGRAVATED - KNIFE / CUTTING INSTRUMENT`, etc.), **tipos de robo** (`RETAIL THEFT`, `POCKET-PICKING`, `PURSE-SNATCHING`, `THEFT FROM MOTOR VEHICLE`, etc.), **posesión y distribución de narcóticos** (`POSSESS - COCAINE`, `POSSESS - HEROIN`, `MANUFACTURE / DELIVER - CRACK`, etc.), **armas** (`UNLAWFUL POSSESSION - HANDGUN`, `UNLAWFUL USE - OTHER FIREARM`, etc.), **violaciones de orden** (`VIOLATE ORDER OF PROTECTION`, `VIOLATION OF BAIL BOND - DOMESTIC VIOLENCE`, etc.), y otros como `FIRST DEGREE MURDER`, `FORCIBLE ENTRY`, `DOMESTIC BATTERY SIMPLE`, `CYBERSTALKING`, entre muchos más. |
| `fbi_cd` | Contiene 26 códigos del FBI para clasificación federal de crímenes: `01A`, `01B`, `02`, `03`, `04A`, `04B`, `05`, `06`, `07`, `08A`, `08B`, `09`, `10`, `11`, `12`, `13`, `14`, `15`, `16`, `17`, `18`, `19`, `20`, `22`, `24`, `26`. Siguen el estándar Uniform Crime Reporting (UCR) del FBI. |
| `iucr` | Contiene 332 códigos del Illinois Uniform Crime Reporting. Siguen un formato numérico (`0110`, `0820`, `1310`, etc.) o alfanumérico (`031A`, `141B`, etc.) que representa subcategorías específicas de crimen. Algunos ejemplos: `0110` (Homicidio en primer grado), `0810` (Robo sobre $500), `1310` (Daño criminal a propiedad). |
| `location_description` | 131 tipos de lugar. Incluye categorías como `STREET`, `RESIDENCE`, `APARTMENT`, `SIDEWALK`, `PARKING LOT`, `ALLEY`, `GAS STATION`, `SCHOOL - PUBLIC BUILDING`, `CTA TRAIN`, `RESTAURANT`, entre otros. Cubre tanto espacios públicos como privados, y locaciones especiales como instalaciones del CTA, aeropuertos y propiedades del gobierno. |
| `beat` | 274 valores que representan unidades de patrullaje policial. La mayoría siguen un formato de 4 dígitos donde los primeros 2 indican el distrito (e.g., `1011`, `2532`, `0614`). Algunos valores de 3 dígitos (`111`, `112`) corresponden a códigos históricos o especiales. |
| `ward` | 50 distritos político-administrativos de Chicago (del `1` al `50`), más un valor vacío que será tratado en limpieza. |

No se encontraron valores inesperados en ninguna columna categórica. Todos los valores son consistentes con el sistema de registro policial de Chicago, con excepción de los strings vacíos ya documentados en la sección de valores nulos y vacíos.

## Conteo de Tuplas por Categoría

### `arrest`
| Valor | Conteo |
|---|---|
| N | 196,993 |
| Y | 35,595 |

El 84.7% de los crímenes no resultaron en arresto.

### `domestic`
| Valor | Conteo |
|---|---|
| N | 188,108 |
| Y | 44,480 |

El 19.1% de los crímenes son de violencia doméstica.

### `primary_description`
| Categoría | Conteo |
|---|---|
| THEFT | 53,067 |
| BATTERY | 42,414 |
| CRIMINAL DAMAGE | 26,117 |
| ASSAULT | 21,215 |
| MOTOR VEHICLE THEFT | 17,653 |
| OTHER OFFENSE | 15,921 |
| DECEPTIVE PRACTICE | 13,800 |
| BURGLARY | 11,140 |
| NARCOTICS | 6,720 |
| CRIMINAL TRESPASS | 5,367 |
| ROBBERY | 5,365 |
| WEAPONS VIOLATION | 5,036 |
| CRIMINAL SEXUAL ASSAULT | 1,628 |
| OFFENSE INVOLVING CHILDREN | 1,517 |
| SEX OFFENSE | 1,293 |
| PUBLIC PEACE VIOLATION | 1,078 |
| INTERFERENCE WITH PUBLIC OFFICER | 913 |
| STALKING | 577 |
| HOMICIDE | 441 |
| ARSON | 348 |
| CONCEALED CARRY LICENSE VIOLATION | 222 |
| PROSTITUTION | 189 |
| LIQUOR LAW VIOLATION | 188 |
| INTIMIDATION | 180 |
| KIDNAPPING | 90 |
| OBSCENITY | 53 |
| PUBLIC INDECENCY | 18 |
| HUMAN TRAFFICKING | 17 |
| GAMBLING | 12 |
| OTHER NARCOTIC VIOLATION | 8 |
| NON-CRIMINAL | 1 |

Los cinco crímenes más frecuentes (`THEFT`, `BATTERY`, `CRIMINAL DAMAGE`, `ASSAULT`, `MOTOR VEHICLE THEFT`) representan el 77% del total de registros.

### `secondary_description`

Con 310 valores distintos, se listan únicamente los 10 más frecuentes:

| Subcategoría | Conteo |
|---|---|
| SIMPLE | 29,871 |
| DOMESTIC BATTERY SIMPLE | 18,569 |
| TO VEHICLE | 15,258 |
| $500 AND UNDER | 14,945 |
| AUTOMOBILE | 13,704 |
| OVER $500 | 13,553 |
| RETAIL THEFT | 12,868 |
| TO PROPERTY | 10,447 |
| THEFT FROM MOTOR VEHICLE | 5,927 |
| BURGLARY FROM MOTOR VEHICLE | 5,232 |

### `fbi_cd`

| Código FBI | Conteo |
|---|---|
| 06 (Theft) | 58,299 |
| 08B (Criminal Damage) | 35,732 |
| 14 (Other Offense) | 26,117 |
| 26 (Other) | 18,639 |
| 08A (Battery) | 18,354 |
| 07 (Motor Vehicle Theft) | 17,653 |
| 11 (Deceptive Practice) | 12,900 |
| 04B (Assault) | 7,092 |
| 18 (Narcotics) | 6,719 |
| 04A (Aggravated Assault) | 6,451 |
| Resto de códigos | 24,632 |

### `iucr`

Con 332 códigos distintos, se listan los 10 más frecuentes:

| Código IUCR | Conteo |
|---|---|
| 0486 (Domestic Battery Simple) | 18,569 |
| 0460 (Simple Battery) | 15,208 |
| 0820 (Theft $500 and Under) | 14,945 |
| 1320 (Criminal Damage to Vehicle) | 14,677 |
| 0560 (Retail Theft) | 14,311 |
| 0910 (Motor Vehicle Theft - Automobile) | 13,704 |
| 0810 (Theft Over $500) | 13,553 |
| 0860 (Retail Theft) | 12,868 |
| 1310 (Criminal Damage to Property) | 10,447 |
| 0710 (Theft from Motor Vehicle) | 5,927 |

### `location_description`

Con 131 valores distintos, se listan los 10 más frecuentes:

| Tipo de Lugar | Conteo |
|---|---|
| STREET | 62,768 |
| APARTMENT | 45,355 |
| RESIDENCE | 27,094 |
| SIDEWALK | 11,685 |
| PARKING LOT / GARAGE (NON RESIDENTIAL) | 8,604 |
| SMALL RETAIL STORE | 8,409 |
| DEPARTMENT STORE | 5,511 |
| RESTAURANT | 5,191 |
| ALLEY | 4,968 |
| OTHER (SPECIFY) | 4,156 |

### `beat`

Con 274 valores distintos, se listan los 10 beats con más incidencia:

| Beat | Conteo |
|---|---|
| 1834 | 2,918 |
| 123 | 2,018 |
| 1831 | 1,845 |
| 421 | 1,738 |
| 1214 | 1,681 |
| 112 | 1,638 |
| 624 | 1,569 |
| 1832 | 1,545 |
| 631 | 1,542 |
| 222 | 1,539 |

### `ward`

Con 50 vecindarios, se listan los 10 con más incidencia:

| Ward | Conteo |
|---|---|
| 27 (Near West Side, West Town) | 11,154 |
| 28 (West Garfield Park, Austin) | 10,368 |
| 42 (Loop, Streeterville) | 8,715 |
| 6 (Chatham, Greater Grand Crossing) | 8,707 |
| 24 (North Lawndale) | 7,989 |
| 20 (Woodlawn, Washington Park) | 7,952 |
| 4 (Kenwood, Oakland) | 7,892 |
| 17 (West Englewood, Chicago Lawn) | 7,255 |
| 16 (Englewood, West Englewood) | 7,085 |
| 21 (Auburn Gresham, Washington Heights) | 6,978 |

## Actividad C: Limpieza de Datos (`cleaning` schema)

**Objetivo:** Transformar los datos crudos en un conjunto de información íntegro, tipado correctamente y libre de redundancias para facilitar el análisis posterior.

---

### 1. Estrategia de Deduplicación y Consistencia

**Hallazgo Crítico:** Durante el análisis preliminar, identificamos 18 `case_numbers` con múltiples registros asociados. Tras una inspección detallada, confirmamos que esto ocurre principalmente en casos de homicidio, donde la policía genera nuevos registros para actualizar la hora del incidente conforme avanza la investigación, en lugar de sobreescribir el anterior.

**Solución Técnica:** Implementamos una **ventana temporal** para garantizar que cada crimen sea único en nuestra base de datos, conservando exclusivamente la versión más reciente (la más precisa) de cada expediente.

```sql
-- Conservar solo el último estado del reporte policial (equivalente al script 02)
ROW_NUMBER() OVER(
    PARTITION BY TRIM(UPPER(case_number))
    ORDER BY TO_TIMESTAMP(TRIM(date_occurrence), 'MM/DD/YYYY HH12:MI:SS AM') DESC
) = 1
```

**Resultado:** Se consolidaron 232,593 registros únicos, eliminando 22 registros que representaban actualizaciones históricas o errores de carga idénticos.

---

### 2. Transformaciones de Tipado y Normalización

Para optimizar el rendimiento de las consultas y permitir cálculos matemáticos (especialmente en análisis geográfico y temporal), realizamos las siguientes conversiones de esquema:

| Columna | Origen (Raw) | Destino (Cleaning) | Lógica de Negocio Aplicada |
| :--- | :--- | :--- | :--- |
| `date_occurrence` | TEXT | `incident_timestamp` TIMESTAMP | Mismo instante que en raw, parseado con `TO_TIMESTAMP(..., 'MM/DD/YYYY HH12:MI:SS AM')`. |
| `arrest`, `domestic` | TEXT (Y/N) | BOOLEAN | Transformación de indicadores de texto a valores lógicos (`TRUE`/`FALSE`). |
| `beat`, `ward` | TEXT | INTEGER | Limpieza de caracteres no numéricos y asignación de tipos enteros para indexación. |
| `x_coordinate`, `y_coordinate` | TEXT | DOUBLE PRECISION | Conservadas (proyección Illinois State Plane); en `03` se proyectan a entero en `normalization.incident`. |
| `latitude`, `longitude` | TEXT | DOUBLE PRECISION | Conversión a punto flotante de alta precisión para habilitar funciones geoespaciales. |
| `case_number`, `block`, `iucr`, `secondary_description`, `location_description`, `fbi_cd` | TEXT | TEXT (con `TRIM` / `UPPER` según columna en el script) | Estandarización y nulos silenciosos (`NULLIF(TRIM(...), '')`) donde aplica. |

**Eliminación de redundancias (solo en limpieza):**
*   **Columna `location` (raw):** no se copia a `cleaning.chicago_crimes`; es redundante con `latitude` y `longitude`.
*   **Coordenadas X/Y:** permanecen en `cleaning` y en la tabla de hechos normalizada; no se descartan en `02`.

---

### 3. Técnicas Avanzadas de Ingeniería de Datos

*   **Tratamiento de Nulos Silenciosos:** Aplicamos `NULLIF(TRIM(columna), '')` en todas las columnas críticas. Esto es vital porque el dataset original contenía espacios en blanco que PostgreSQL no reconoce como nulos, lo que podría sesgar los promedios y conteos estadísticos.
*   **Fuzzy Matching (Extensión `fuzzystrmatch`):** Utilizamos el algoritmo de **Distancia de Levenshtein** para la limpieza de texto. Esta técnica permite identificar qué tan similares son dos palabras; así, pudimos detectar errores de dedo en la captura manual de los delitos y unificarlos bajo una sola categoría correcta de forma automática.
*   **Agrupación de Categorías y "Low Frequency":** Para mejorar la claridad de las visualizaciones, consolidamos variantes de ubicaciones (ej. distintos formatos de `STREET` y `SIDEWALK`). Aquellas categorías con menos de 5 registros en todo el año fueron reclasificadas como `OTHER (LOW FREQUENCY)` para reducir el ruido estadístico.
*   **Imputación Lógica de `FBI_CD`:** Detectamos registros donde faltaba el código federal del FBI. En lugar de borrarlos, creamos un mapeo interno basado en el código local `IUCR`. Si un registro tenía el código local pero no el federal, el script le asigna automáticamente el código correspondiente basado en los patrones encontrados en el resto del dataset.

---

### 4. Ejecución del Proceso

El script de limpieza es **idempotente** (utiliza un *refresh* destructivo del schema `cleaning`), asegurando que siempre se trabaje sobre una versión limpia de los datos.

```bash
# Desde la raíz del repositorio:
psql -U tuUsuario -d crimenes -f pipeline_scripts/02_data_cleaning.sql
```

**Estado final:** tabla `cleaning.chicago_crimes` con **15 columnas** (`case_number`, `incident_timestamp`, `block`, `iucr`, `primary_description`, `secondary_description`, `location_description`, `arrest`, `domestic`, `beat`, `ward`, `fbi_cd`, `x_coordinate`, `y_coordinate`, `latitude`, `longitude`), tipos optimizados y lista para `03_data_normalization.sql`.

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
normalization.beat            (beat_id SERIAL PK, beat VARCHAR(10) UNIQUE NOT NULL)
normalization.ward          (ward_id SMALLINT PK)              -- clave = número de ward
normalization.fbi_code      (fbi_cd VARCHAR(10) PK)
normalization.iucr          (iucr_id SERIAL PK, iucr VARCHAR(10) UNIQUE NOT NULL,
                             primary_description, secondary_description,
                             index_code, active,                -- reservados; NULL si no vienen del cleaning
                             fbi_cd VARCHAR REFERENCES normalization.fbi_code(fbi_cd))
normalization.location_type (location_type_id SERIAL PK, location_description VARCHAR(200) UNIQUE)

-- Tabla de hechos (atributos no descompuestos en catálogos + FKs)
normalization.incident      (incident_id SERIAL PK, case_number VARCHAR(20) UNIQUE NOT NULL,
                             date_occurrence TIMESTAMP,         -- desde cleaning.incident_timestamp
                             block VARCHAR(200),
                             arrest BOOLEAN, domestic BOOLEAN,
                             x_coordinate INTEGER, y_coordinate INTEGER,
                             latitude NUMERIC(12,9), longitude NUMERIC(12,9),
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

4. **Llaves:** `beat`, `iucr` y `location_type` usan `SERIAL` como PK surrogada; `ward` usa el número de ward como PK (`SMALLINT`); `fbi_code` usa `fbi_cd` como PK natural. Las claves naturales relevantes se preservan con `UNIQUE` donde aplica.

5. **Índices post-carga:** Se crean 6 índices en las columnas de mayor uso analítico (`beat_id`, `ward_id`, `iucr_id`, `date_occurrence`, `arrest`) al final para optimizar sin ralentizar inserts masivos.

**Ejecución:**
```bash
# Desde la raíz del repositorio:
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

El script exporta **diez** conjuntos de resultados como CSV bajo `results_csv/` (`01_tendencia_mensual.csv` … `10_top20_hotspots_bloques.csv`) usando `\o` y `\pset format csv`. Debe ejecutarse **después** de `03_data_normalization.sql` (las consultas 1–4, 8–10 leen `normalization.*`).

**Origen de datos por bloque:**

| Consultas | Esquema principal | Notas |
| :--- | :--- | :--- |
| 1–4 | `normalization` | Tendencia mensual, tasa de arresto por tipo, variación mes–mes por ward, franja horaria (incluyen `RANK`, `LAG`, ventanas). |
| 5–7 | `raw` | Top beats por distrito, evolución mensual agregada, porcentaje por tipo de ubicación — **sin** deduplicación ni reglas de limpieza; pueden incluir filas duplicadas por `case_number`. |
| 8–10 | `normalization` | Día de la semana, domésticos vs no domésticos, hotspots por `block`. |

Las secciones narrativas siguientes se centran en las cuatro primeras consultas (ventanas sobre datos normalizados); las preguntas 5–7 están desarrolladas más abajo y reflejan el SQL actual (incluido el uso de `raw` donde aplica).

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

# Análisis de Preguntas Clave

> Los hallazgos de las **consultas 1–4 y 8–10** se basan en el esquema `normalization` (deduplicación por `case_number`, nulos normalizados, etc.). Las **consultas 5–7** leen `raw.chicago_crimes`; interpreta sus totales como datos crudos, no necesariamente alineados con los 232,593 incidentes únicos post-limpieza.

---

## Query 5: 3 zonas de patrullaje (beat) con mayor cantidad de crímenes dentro de cada distrito policial *(fuente: `raw.chicago_crimes`)*

El distrito policial se obtiene de los primeros 2 dígitos del `beat` (rellenando con ceros a la izquierda para los beats de 3 dígitos).

El beat `1834` del distrito 18 destaca como el de mayor incidencia en todo Chicago con 2,918 crímenes, casi 1,000 más que el segundo lugar del mismo distrito (`1831`, con 1,842). En general, los distritos 1, 6, 12 y 18 concentran los beats con mayor actividad criminal, lo que apunta a zonas del centro, norte y noroeste de la ciudad como las más afectadas.

| Distrito | #1 Beat | #2 Beat | #3 Beat |
|---|---|---|---|
| 1 | 123 (2,018) | 112 (1,638) | 111 (1,515) |
| 6 | 624 (1,569) | 631 (1,542) | 612 (1,438) |
| 12 | 1214 (1,681) | 1224 (1,479) | 1232 (1,456) |
| 18 | 1834 (2,918) | 1831 (1,842) | 1832 (1,545) |
| 25 | 2533 (1,326) | 2512 (1,295) | 2521 (932) |

*Se muestran los distritos con mayor incidencia. El dataset contiene 25 distritos en total.*

---

## Query 6: ¿Cómo evoluciona la criminalidad mes a mes? ¿Cuál fue el aumento o disminución exacta de incidentes respecto al mes anterior? *(fuente: `raw.chicago_crimes`)*

| Mes | Conteo | Diferencia | Cambio % |
|---|---|---|---|
| 2025-04 | 1,267 | — | — |
| 2025-05 | 20,489 | +19,222 | — * |
| 2025-06 | 21,101 | +612 | +2.99% |
| 2025-07 | 22,646 | +1,545 | +7.32% |
| 2025-08 | 21,317 | -1,329 | -5.87% |
| 2025-09 | 20,327 | -990 | -4.64% |
| 2025-10 | 20,957 | +630 | +3.10% |
| 2025-11 | 18,391 | -2,566 | -12.24% |
| 2025-12 | 17,452 | -939 | -5.11% |
| 2026-01 | 16,825 | -627 | -3.59% |
| 2026-02 | 16,369 | -456 | -2.71% |
| 2026-03 | 18,832 | +2,463 | +15.05% |
| 2026-04 | 16,592 | -2,240 | -11.89% |

*\* El cambio de abril a mayo 2025 no es interpretable: abril 2025 solo incluye 2 días (el dataset arranca el 29 de abril), por lo que su conteo de 1,267 no es comparable.*

El pico de criminalidad ocurre en **julio 2025** con 22,646 incidentes, consistente con la tendencia estacional de mayor actividad en verano. A partir de agosto comienza un descenso sostenido que llega a su mínimo en **febrero 2026** (16,369), el mes más frío. Marzo 2026 muestra un repunte del 15.05%, señal del inicio de la temporada cálida.

---

## Query 7: Porcentaje del total histórico de crímenes aporta cada tipo de ubicación al problema de inseguridad *(fuente: `raw.chicago_crimes`)*

| Tipo de Ubicación | Conteo | Porcentaje |
|---|---|---|
| STREET | 62,755 | 27.12% |
| APARTMENT | 45,349 | 19.59% |
| RESIDENCE | 27,094 | 11.71% |
| SIDEWALK | 11,685 | 5.05% |
| PARKING LOT / GARAGE (NON RESIDENTIAL) | 8,604 | 3.72% |
| SMALL RETAIL STORE | 8,409 | 3.63% |
| DEPARTMENT STORE | 5,511 | 2.38% |
| RESTAURANT | 5,191 | 2.24% |
| ALLEY | 4,967 | 2.15% |
| OTHER (SPECIFY) | 4,156 | 1.80% |
| Resto (120 tipos) | 47,279 | 20.61% |

La **calle** concentra el 27.12% de todos los crímenes — más de uno de cada cuatro incidentes ocurre en la vía pública. Los **espacios residenciales** combinados (`APARTMENT` + `RESIDENCE` + `RESIDENCE - PORCH / HALLWAY`) suman el **32.51%**, superando incluso a la calle. El top 10 de ubicaciones representa el **79.39%** del total, lo que indica una alta concentración contextual de los crímenes. En contraste, los 120 tipos de ubicación restantes apenas suman el 20.61%.

---

## Ejecución de Queries

```bash
# Desde la raíz del repositorio (requiere carpeta results_csv/):
psql -U tuUsuario -d crimenes -f exploration_queries/02_analytical_queries.sql
```

Salida: **10 archivos CSV** en `results_csv/`, listos para visualización o reporte.

---

# Resumen de Resultados

| Métrica | Valor |
| :--- | :--- |
| Registros raw cargados (corrida de referencia, Actividad B) | 232,615 |
| Registros después de dedup (cleaning / incident) | 232,593 |
| Relvars en 4FN | 6 |
| Catálogos únicos (beats, wards, IUCRs, FBI codes) | 274 + 50 + 333 + 26 = 683 |
| Salidas CSV del script analítico | 10 (`results_csv/`) |
| Tasa de arresto global | 15.5% (36,071 / 232,593) |
| Mayor volumen de delito | Theft (53,079 incidentes, 22.8% del total) |
| Mes de mayor criminalidad | Julio (22,643 incidentes) |
| Franja horaria de riesgo máximo | Tarde 12-17h (31.4% del total) |

*Las métricas numéricas corresponden al CSV y corridas documentadas en el informe; otra versión del archivo fuente puede cambiar conteos ligeramente.*

---

# Notas Técnicas

## Reproducibilidad

El pipeline es 100% reproducible y autocontenido:
- Solo requiere `data/raw_data.csv` (descargable del Chicago Data Portal o del enlace del equipo)
- Todos los catálogos se derivan del cleaning con `SELECT DISTINCT`
- Sin archivos CSV auxiliares para catálogos, sin *hardcoding* de dimensiones de negocio en los scripts del pipeline
- Scripts idempotentes (refresh destructivo, `DROP CASCADE` de esquemas)
- **Cifras en el README:** son referencia del snapshot usado en el proyecto; valida con tus propios `COUNT(*)` si cambias el CSV

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

## Conclusiones

Chicago no es una ciudad uniformemente peligrosa. Es una ciudad con patrones. La criminalidad no se distribuye al azar: tiene estaciones, tiene geografías y afecta desproporcionadamente los espacios donde la gente vive y transita en su día a día. El análisis deja claro que los crímenes siguen ciclos predecibles, se concentran en zonas específicas y golpean sobre todo en la calle y en el hogar, que son precisamente los lugares donde uno menos debería tener que cuidarse.

Quizás el hallazgo más revelador no es dónde o cuándo ocurren los crímenes, sino cuáles se resuelven. La baja tasa de arresto en los delitos de mayor volumen como el robo o la batería contrasta con la alta efectividad en infracciones regulatorias. Esto sugiere que el sistema policial está más orientado a la ejecución de normas específicas que a la protección frente a los delitos que más impactan a la gente común. El crimen que más se sufre es, paradójicamente, el que menos consecuencias tiene para quien lo comete.

Lo que más llama la atención es que la tasa de arresto se mantiene prácticamente igual a lo largo de todo el año, incluso cuando los incidentes aumentan casi un 40% en verano. El sistema no se adapta al pico de demanda, simplemente lo absorbe con la misma eficiencia de siempre. Eso, más que cualquier número, define el verdadero reto de seguridad pública en Chicago.

Estos hallazgos iluminan un problema real y actual de seguridad pública en Chicago. Reconocer un problema es siempre el primer paso para resolverlo, y lo que los datos revelan es exactamente eso: un punto de partida concreto hacia una ciudad más segura. Vale la pena destacar que esta metodología es completamente replicable en cualquier conjunto de datos de cualquier ciudad o país. Con el enfoque correcto y la voluntad de mirar los números de frente, estamos un paso más cerca de construir comunidades más seguras para todos.
