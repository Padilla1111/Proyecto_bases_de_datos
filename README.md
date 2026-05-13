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

Para este proyecto se utilizan los datos proporcionados por el portal de datos de Chicago. Se puede acceder a los datos actualizados al día de la descarga en [este link (Crimes - One Year Prior to Present)](https://data.cityofchicago.org/Public-Safety/Crimes-One-year-prior-to-present/x2n5-8w5q/about_data). Pero **para fines de consistencia** en el proyecto, se usó el archivo que contiene datos desde el 28 de Abril de 2025 hasta el 28 de Abril de 2026. El archivo está ubicado en [este link](https://drive.google.com/drive/folders/10-k0SMeGqK_xzf3rYdQ1Y15gDT14BL4y?usp=sharing)
* **Instrucciones:** Para descargar el archivo exacto, haz clic en el los tres puntos a la derecha del nombre del archivo con etiqueta "Más acciones", y selecciona el botón **Descargar**.

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
│   └── 03_data_normalization.sql                     <- Script de normalización de relaciones (i.e., actividad D)
│
└── exploration_queries                               <- Scripts de SQL para exploración de datos
    ├── 01_raw_data_exploration.sql                   <- Consultas de exploración de datos en bruto (i.e., soporte de actividad B)
    └── 02_analytical_queries.sql                     <- Consultas de interés sobre los datos normalizados (i.e., soporte de actividad E)
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
psql -U [tuUsuario] -d crimenes -f exploration_queries/01_raw_data_exploration.sql
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


## Actividad C: Limpieza de Datos

El proceso de limpieza sigue una metodología de **refresh destructivo** mediante el esquema `cleaning`. Esto garantiza la **idempotencia** del proceso: cada ejecución genera desde cero el esquema y las tablas correspondientes, asegurando un estado consistente y libre de errores de ejecuciones previas. El diseño responde directamente a los hallazgos del Análisis Exploratorio de Datos (EDA) preliminar.

### 1. Ejecución del proceso
Para ejecutar la limpieza de datos, asegúrate de estar en la raíz del proyecto en tu terminal y ejecuta el siguiente comando:

```bash
psql -U [tuUsuario] -d crimenes -f pipeline_scripts/02_data_cleaning.sql
```

### 2. Actividades de Limpieza Realizadas
Siguiendo los requerimientos del **Inciso C** y la checklist del EDA, se implementaron las siguientes transformaciones técnicas:

* **Eliminación de Duplicados Lógicos (Actualizaciones):** Se detectaron 18 expedientes con actualizaciones progresivas. Se implementó una *Window Function* (`ROW_NUMBER() OVER PARTITION BY case_number ORDER BY date_occurrence DESC`) para aislar y conservar únicamente la actualización más reciente de cada caso.
* **Eliminación de Columna Redundante:** Se descartó la columna `location` de la tabla final, ya que su formato de tupla espacial era completamente derivable de `latitude` y `longitude`, evitando redundancia en el esquema.
* **Conversión de Tipos de Datos:**
    * **Temporales:** Transformación de `date_occurrence` (texto) a tipo `TIMESTAMP` mediante la máscara `MM/DD/YYYY HH12:MI:SS AM` para permitir operaciones como ordenamiento cronológico y filtros por rango.
    * **Booleanos:** Traducción de los indicadores `Y/N` de las columnas `arrest` y `domestic` a tipo `BOOLEAN` nativo de PostgreSQL, para reflejar correctamente su naturaleza binaria.
    * **Numéricos:** Cast de `x_coordinate`, `y_coordinate`, `latitude` y `longitude` a `DOUBLE PRECISION` (FLOAT).
    * **Enteros:** Conversión de `ward` y `beat` a `INTEGER` para permitir ordenamientos y análisis espacial.
* **Tratamiento de Valores Nulos:** Uso de `NULLIF(TRIM(columna), '')` para asegurar que los strings vacíos detectados en el EDA (ej. en `location_description`, coordenadas y `ward`) sean tratados como nulos reales, protegiendo las funciones de agregación.
* **Estandarización de Texto:** Uso de funciones `TRIM` y `UPPER` en columnas categóricas (`primary_description`, `location_description`, `block`) para eliminar espacios inconsistentes.
* **Consolidación de Categorías:** Uso de expresiones regulares y reglas explícitas para normalizar categorías de ubicación. Se consolidan variantes relacionadas con "STREET" y "SIDEWALK" como categorías separadas.
* **Corrección de Errores de Captura:** Empleo de la extensión `fuzzystrmatch` (distancia de **Levenshtein**) para corregir errores menores de escritura en categorías delictivas (ej. HOMICID → HOMICIDE).
* **Manejo de Outliers:** Agrupación bajo la categoría `OTHER (LOW FREQUENCY)` para descripciones de ubicación con menos de 5 registros, optimizando la claridad de futuras visualizaciones.

### 3. Justificación Técnica
La estrategia de limpieza se diseñó bajo los siguientes pilares de Ingeniería de Datos:

1. **Aislamiento de Datos (Staging):** Se utiliza el esquema `cleaning` para no alterar la tabla `raw`. Esto permite re-procesar los datos en cualquier momento sin necesidad de re-importar el CSV original de +200k registros.
2. **Decisiones Basadas en Datos (EDA-Driven):** La deduplicación no fue arbitraria; el uso de ventanas de tiempo resolvió el problema de actualización de expedientes policiales detectado en la fase exploratoria.
3. **Optimización Analítica:** La conversión a tipos de datos nativos (`TIMESTAMP`, `BOOLEAN`, `INTEGER` y `DOUBLE PRECISION`) y la eliminación de columnas redundantes reducen significativamente el espacio en disco y aceleran el rendimiento de las consultas.
4. **Integridad y Calidad:** La normalización de texto, el uso de distancias de edición y el manejo correcto de valores nulos garantizan que las agrupaciones (`GROUP BY`) devuelvan resultados analíticos precisos y consistentes.

## Actividad D: Normalización a Cuarta Forma Normal (4FN)

El proceso de normalización sigue la misma metodología de **refresh destructivo** mediante el schema `normalization`, garantizando idempotencia. El diseño se basa en el análisis de dependencias funcionales y multivaluadas derivado del EDA preliminar y de los catálogos oficiales del Chicago Police Department.

### 1. Ejecución del proceso

Para ejecutar la normalización, asegúrate de estar en la raíz del proyecto y de contar con los archivos de referencia en la carpeta `normalizacion_proyecto_final/`:

```bash
psql -U [tuUsuario] -d crimenes -f pipeline_scripts/03_data_normalization.sql
```

### 2. Dependencias Funcionales Identificadas

A partir del análisis del esquema raw, se identificaron las siguientes dependencias funcionales no triviales:

| # | Dependencia | Justificación |
|---|---|---|
| (1) | `case_number → {todos los atributos}` | El número de caso es la clave del registro policial. |
| (2) | `iucr → primary_description, secondary_description, index_code, active` | Los 332 códigos IUCR tienen descripciones predefinidas en el catálogo oficial de Illinois. |
| (3) | `iucr → fbi_cd` | Dependencia transitiva: el código IUCR determina unívocamente la clasificación del FBI. |
| (4) | `fbi_cd → description, index_status, crime_type` | Los 26 códigos UCR del FBI tienen clasificaciones fijas. |
| (5) | `beat → district_id` | Los 274 beats de Chicago pertenecen cada uno a un único distrito policial. |
| (6) | `district_id → district_name` | Los 22 distritos tienen nombres oficiales únicos. |
| (7) | `ward_id → neighborhoods` | Los 50 wards de Chicago tienen colonias asociadas en el catálogo de la ciudad. |

**Dependencias Multivaluadas:** No se identificaron MVDs independientes en el diseño. Cada incidente registra exactamente un valor de `iucr`, un `beat`, un `ward` y un tipo de ubicación, por lo que no existen hechos multivaluados independientes entre sí. Alcanzar 4FN en este dataset equivale a eliminar todas las dependencias transitivas y aislar cada tipo de hecho en su propia relvar.

### 3. Relvars Resultantes

La descomposición produce 7 tablas, cada una en 4FN:

| Relvar | Clave Primaria | Clave Alterna | Hecho registrado |
| :--- | :--- | :--- | :--- |
| `normalization.district` | `district_id` | — | Nombre del distrito policial |
| `normalization.beat` | `beat_id` | `beat` | Distrito al que pertenece el beat |
| `normalization.ward` | `ward_id` | — | Colonias asociadas al ward |
| `normalization.fbi_code` | `fbi_cd` | — | Clasificación UCR del FBI |
| `normalization.iucr` | `iucr_id` | `iucr` | Descripción del código IUCR y su FBI_CD |
| `normalization.location_type` | `location_type_id` | `location_description` | Tipo de lugar del incidente |
| `normalization.incident` | `incident_id` | `case_number` | Hechos directos del incidente policial |

### 4. Justificación Técnica

La estrategia de normalización se diseñó bajo los siguientes criterios:

1. **Eliminación de Redundancia por FDs Transitivas:** La cadena `case_number → iucr → fbi_cd → {description, ...}` violaba BCNF al almacenar las 26 descripciones del FBI repetidas en cada uno de los ~200,000 registros. Aislar `fbi_code` e `iucr` en sus propias relvars elimina esta redundancia.
2. **Uso de Catálogos Oficiales:** Las tablas de referencia (`district`, `beat`, `ward`, `fbi_code`, `iucr`) se poblan desde los catálogos oficiales del Chicago Police Department, garantizando consistencia con la fuente original de los datos.
3. **Llaves Surrogadas:** Se generan claves primarias subrogadas (`SERIAL`) en todas las tablas, tal como se anticipó en la nota del dataset original. Las claves naturales se preservan como claves alternas (`UNIQUE`).
4. **Mapeo IUCR → FBI_CD basado en datos:** La dependencia transitiva `iucr → fbi_cd` se deriva directamente de los datos crudos (no del xlsx externo), ya que cada registro del dataset contiene ambos códigos. Esto evita inconsistencias entre el catálogo externo y los datos reales cargados.
5. **Índices Post-Carga:** Los índices sobre las columnas de mayor uso analítico (`beat_id`, `ward_id`, `iucr_id`, `date_occurrence`, `arrest`) se crean al final del script para evitar el costo de reindexación incremental durante la inserción masiva.

## Actividad E: Consultas Analíticas

Las consultas de interés se ubican en `exploration_queries/02_analytical_queries.sql` y se ejecutan directamente sobre el schema `normalization`.

### 1. Ejecución

```bash
psql -U [tuUsuario] -d crimenes -f exploration_queries/02_analytical_queries.sql
```

### 2. Consultas Implementadas

| # | Pregunta analítica |
| :--- | :--- |
| 1 | ¿En qué mes del año ocurren más crímenes? ¿Varía la tasa de arresto estacionalmente? |
| 2 | ¿Qué tipos de crimen tienen la tasa de arresto más alta y más baja (con más de 100 incidentes)? |
| 3 | ¿Qué distritos concentran el mayor volumen de criminalidad y qué porcentaje del total representan? |
| 4 | ¿En qué franja horaria se concentran más delitos y cómo varía la tasa de arresto entre franjas? |
