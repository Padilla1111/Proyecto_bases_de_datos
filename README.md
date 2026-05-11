# Proyecto BD: Análisis de Criminalidad en Chicago (Último Año)

## Integrantes
* **Luis Fernando Reyes Altamirano** - Clave Única: 214734 - [LuisRyes](https://github.com/LuisRyes)
* **Ismael Cabrera Arroyo** - Clave Única: 217632 - [mayelmais](https://github.com/mayelmais)
* **Rodrigo Flores Covarrubias** - Clave Única: 217893 - [covaconv](https://github.com/covaconv)
* **Juan Pablo Padilla** - Clave Única: 213650 - [Padilla1111](https://github.com/Padilla1111)
* **Martina Echeverría** - Clave Única: 214173 - [martinaecheverria](https://github.com/martinaecheverria)


## Introducción

Este proyecto analiza los incidentes criminales reportados en la ciudad de Chicago. Originalmente enfocado en el histórico desde 2001, para fines de replicación y eficiencia técnica se utiliza el dataset de incidentes del último año. La información es recolectada por el **Chicago Police Department** mediante el sistema CLEAR (*Citizen Law Enforcement Analysis and Reporting*) y se publica a través del **Chicago Data Portal**.

* **Propósito de recolección:** Promover la transparencia, la rendición de cuentas institucional y facilitar el análisis de seguridad pública para la toma de decisiones.
* **Frecuencia de actualización:** Diaria.

**Objetivo del Proyecto:**
El objetivo principal es transformar el conjunto de datos original de una estructura plana a un **esquema relacional robusto en PostgreSQL**. Se aplicarán procesos de limpieza, estandarización y normalización hasta **Cuarta Forma Normal (4NF)** para eliminar redundancias y asegurar la consistencia de la información. Posteriormente, se desarrollarán consultas SQL avanzadas —incluyendo agregaciones, funciones de ventana e índices— para analizar tendencias temporales, tasas de arresto y distribución geográfica de incidentes.


### Descripción Técnica de Atributos (Dataset Original)

Para la fase `raw`, se ha respetado la estructura del archivo fuente del último año. La siguiente tabla describe los atributos según aparecen en el CSV original:

| Atributo | Correspondencia CSV | Descripción | Tipo Inicial (Raw) |
| :--- | :--- | :--- | :--- |
| **Case Number** | `CASE#` | Número de registro oficial asignado al caso por la policía. | Texto |
| **Date of Occurrence**| `DATE OF OCCURRENCE` | Fecha y hora exacta del incidente. | Texto (a limpiar) |
| **Block** | `BLOCK` | Dirección anonimizada a nivel de cuadra. | Texto |
| **IUCR** | `IUCR` | Illinois Uniform Crime Reporting code (Código de reporte de crimen). | Texto |
| **Primary Description**| `PRIMARY DESCRIPTION` | Categoría principal del delito (basada en el código IUCR). | Texto |
| **Secondary Description**| `SECONDARY DESCRIPTION` | Detalle específico o subcategoría del delito cometido. | Texto |
| **Location Description**| `LOCATION DESCRIPTION` | Tipo de lugar donde ocurrió el evento (ej. Calle, Residencia). | Texto |
| **Arrest** | `ARREST` | Indica si el incidente resultó en un arresto ("true"/"false"). | Texto (Booleano) |
| **Domestic** | `DOMESTIC` | Indica si fue un incidente relacionado con violencia doméstica. | Texto (Booleano) |
| **Beat** | `BEAT` | Identificador del área de patrullaje más pequeña. | Texto |
| **Ward** | `WARD` | Distrito electoral o concejalía donde ocurrió el incidente. | Texto |
| **FBI CD** | `FBI CD` | Código de clasificación del crimen bajo estándares del FBI. | Texto |
| **X Coordinate** | `X COORDINATE` | Coordenada X del sistema de proyección local de la ciudad. | Texto |
| **Y Coordinate** | `Y COORDINATE` | Coordenada Y del sistema de proyección local de la ciudad. | Texto |
| **Latitude** | `LATITUDE` | Latitud de la ubicación exacta del incidente. | Numérico |
| **Longitude** | `LONGITUDE` | Longitud de la ubicación exacta del incidente. | Numérico |
| **Location** | `LOCATION` | Tupla combinada de coordenadas (Latitud, Longitud). | Texto |

> **Nota sobre el Identificador (ID):** A diferencia del dataset histórico completo, el archivo de "Último Año" no incluye una columna `ID` numérica incremental en la primera posición. Se ha decidido mantener el esquema original en esta fase; se generarán llaves primarias subrogadas y únicas durante la **Actividad D (Normalización)** para garantizar la integridad referencial y cumplir con las formas normales.

**Consideraciones Éticas:**
El análisis de datos de criminalidad conlleva una responsabilidad ética significativa, por lo que el equipo se adhiere a los siguientes criterios:
* **Privacidad y Anonimato:** Se respetará el anonimato de los datos a nivel de cuadra, evitando cruces de información que pudieran facilitar la reidentificación de víctimas o individuos involucrados.
* **Reconocimiento de Sesgos:** Se asume que los datos representan incidentes *reportados* y no la totalidad de los delitos ocurridos, considerando factores institucionales y de subdenuncia.
* **Prevención de la Estigmatización:** El análisis espacial se presentará con el contexto social necesario para evitar generalizaciones o prejuicios sobre zonas geográficas específicas.
* **Responsabilidad en el Uso:** Analizar datos de *open data* implica responsabilidad; aunque sean públicos, pueden permitir reidentificación o amplificar sesgos institucionales. El enfoque del proyecto es técnico y estructural, ya que los datos abiertos no equivalen a un uso éticamente neutro.

## Fuente de datos

Para este proyecto se utilizan los datos proporcionados por el portal de datos de Chicago. Se puede acceder a los datos en [este link (Crimes - One Year Prior to Present)](https://data.cityofchicago.org/Public-Safety/Crimes-One-year-prior-to-present/x2n5-8w5q/about_data).
* **Instrucciones:** Para descargar el archivo exacto, haz clic en el botón **"Export"** en el portal y selecciona el formato **CSV**.

* **Escala:** El dataset contiene aproximadamente 200,000 registros, lo que cumple con el requisito de carga mínima (>5,000 tuplas).

### ⚙️ Configuración para Replicación
Para que los scripts de carga funcionen sin errores, es obligatorio seguir este orden:
1. Crea una carpeta llamada `data` en la raíz del proyecto (si no existe).
2. Guarda el archivo descargado dentro de `/data` con el nombre exacto: `raw_data.csv`.
3. El archivo `.gitignore` ya está configurado para que este CSV no se suba al repositorio.
## Documentación

### Estructura del repositorio
```text
├── README.md                                         <- Documentación para desarrolladores de este proyecto (i.e., reporte escrito)
├── data                                              <- Carpeta para almacenamiento local de datos (Ignorada por Git)
│   ├── .gitignore                                    <- Configuración de archivos excluidos
│   └── raw_data.csv                                  <- (Usuario debe descargar este archivo localmente desde la pagina de Chicago)
│
├── pipeline_scripts                                  <- Scripts de SQL para ejecución del pipeline de datos
│   ├── 01_raw_data_schema_creation_and_load.sql      <- Script de carga inicial (i.e., actividad B)
│   ├── 02_data_cleaning.sql                          <- Script de limpieza de datos (i.e., actividad C)
│   ├── 03_data_normalization.sql                     <- Script de normalización de relaciones (i.e., actividad D)
│   └── 04_analytical_attributes_creation.sql         <- Script de creación de atributos analíticos (i.e., actividad E)
│
└── exploration_queries                               <- Scripts de SQL para exploración de datos
    ├── 01_raw_data_exploration.sql                   <- Consultas de exploración de datos en bruto (i.e., soporte de actividad B)
    ├── ⋅⋅⋅                                           <- Otras consultas en caso de ser requeridas
    └── 0N_analytical_queries.sql                     <- Consultas de interés sobre los datos normalizados (i.e., soporte de actividad 
```

# Carga inicial y análisis preliminar

## Carga Inicial y Ejecución del Script

### Desde la raíz del proyecto, ejecuta:

```bash
psql -U [tuUsuario] -d crimenes -f pipeline_scripts/01_raw_data_schema_creation_and_load.sql
```

Esto creará el schema, la tabla y cargará los datos automáticamente.

### Verificar que funcionó:

```bash
psql -U postgres -d crimenes -c "SELECT COUNT(*) FROM rawc.crimes;"
```
## Análisis preliminar

### Ejecución del proceso
Para ejecutar el análisis preliminar, asegúrate de estar en la raíz del proyecto en tu terminal y ejecuta el siguiente comando:

```bash
psql -d crime_chicago -f exploration_queries/01_raw_data_exploration.sql
```

## Descripción de Columnas y Valores Únicos

Total de tuplas en la tabla: **232,588**

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

El campo `date_occurrence` está almacenado en formato `MM/DD/YYYY HH:MI:SS AM/PM` y cubre exactamente un año de registros:

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

Con 50 distritos, se listan los 10 con más incidencia:

| Ward | Conteo |
|---|---|
| 27 | 11,154 |
| 28 | 10,368 |
| 42 | 8,715 |
| 6 | 8,707 |
| 24 | 7,989 |
| 20 | 7,952 |
| 4 | 7,892 |
| 17 | 7,255 |
| 16 | 7,085 |
| 21 | 6,978 |


## Actividad C: Limpieza de Datos

El proceso de limpieza sigue una metodología de **refresh destructivo** mediante el esquema `cleaning`. Esto garantiza la **idempotencia** del proceso: cada ejecución genera desde cero el esquema y las tablas correspondientes, asegurando un estado consistente y libre de errores de ejecuciones previas.

### 1. Ejecución del proceso
Para ejecutar la limpieza de datos, asegúrate de estar en la raíz del proyecto en tu terminal y ejecuta el siguiente comando:

```bash
psql -d crime_chicago -f pipeline_scripts/02_data_cleaning.sql
```

### 2. Actividades de Limpieza Realizadas
Siguiendo los requerimientos del **Inciso C**, se implementaron las siguientes transformaciones técnicas basadas en el análisis de calidad del dataset:

* **Estandarización de Texto:** Uso de funciones `TRIM` y `UPPER` en columnas categóricas (`primary_description`, `location_description`, `block`) para eliminar espacios inconsistentes y normalizar la entrada de datos.
* **Conversión de Tipos de Datos:**
    * **Temporales:** Transformación de `date_occurrence` (texto) a tipo `TIMESTAMP` mediante la máscara `MM/DD/YYYY HH12:MI:SS AM` para permitir análisis de series de tiempo.
    * **Booleanos:** Traducción de los indicadores `Y/N` de las columnas `arrest` y `domestic` a tipo `BOOLEAN` nativo de PostgreSQL, conservando como `NULL` aquellos valores que no correspondan a `Y` o `N`.
    * **Numéricos:** Cast de `latitude` y `longitude` a `DOUBLE PRECISION`.
    * **Enteros:** Conversión de `ward` a `INTEGER` para permitir ordenamientos numéricos y análisis por distrito político-administrativo.
* **Tratamiento de Valores Nulos:** Uso de `NULLIF(TRIM(columna), '')` para asegurar que los strings vacíos o con espacios sean tratados como nulos reales, evitando sesgos en cálculos estadísticos y funciones de agregación.
* **Consolidación de Categorías:** Uso de expresiones regulares y reglas explícitas para normalizar categorías de ubicación. Se consolidan variantes relacionadas con "STREET" y "SIDEWALK" como categorías separadas para evitar mezclar tipos de ubicación distintos.
* **Corrección de Errores de Captura:** Empleo de la extensión `fuzzystrmatch` (distancia de **Levenshtein**) para corregir errores menores de escritura en categorías delictivas (ej. HOMICID → HOMICIDE).
* **Eliminación de Duplicados:** Uso de `SELECT DISTINCT` durante la carga inicial al esquema `cleaning` para evitar registros duplicados exactos provenientes de la tabla `raw`.
* **Manejo de Outliers:** Agrupación bajo la categoría `OTHER (LOW FREQUENCY)` para descripciones de ubicación con menos de 5 registros, optimizando la claridad de futuras visualizaciones y reportes.

### 3. Justificación Técnica
La estrategia de limpieza se diseñó bajo los siguientes pilares de Ingeniería de Datos:

1. **Aislamiento de Datos (Staging):** Se utiliza el esquema `cleaning` para no alterar la tabla `raw`. Esto permite re-procesar los datos en cualquier momento sin necesidad de re-importar el CSV original de +200k registros.
2. **Optimización Analítica:** La conversión a tipos de datos nativos (`TIMESTAMP`, `BOOLEAN`, `INTEGER` y `DOUBLE PRECISION`) reduce el espacio en disco y habilita el uso de funciones avanzadas de extracción de tiempo y análisis geográfico.
3. **Integridad y Calidad:** La normalización de texto, la eliminación de duplicados y el manejo correcto de valores nulos reducen la fragmentación de datos, asegurando que un `GROUP BY` devuelva resultados precisos y consistentes.
4. **Consistencia Semántica:** La consolidación controlada de categorías evita mezclar valores conceptualmente distintos, manteniendo coherencia en análisis posteriores y visualizaciones.
