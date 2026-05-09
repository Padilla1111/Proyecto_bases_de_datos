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
# Análisis Exploratorio de Datos

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
 
Se encontraron 18 números de caso repetidos en el dataset, algunos apareciendo hasta 4 veces. Al analizar estos registros en detalle, se observó que los duplicados comparten exactamente los mismos valores en todas las columnas excepto en `date_occurrence`, donde las horas registradas son cercanas entre sí pero distintas. Por ejemplo, el caso `JJ309322` aparece 4 veces con horas de 2:50 AM, 2:55 AM, 3:29 AM y 10:10 AM.
 
Esto sugiere que los duplicados no representan crímenes distintos, sino **actualizaciones progresivas del mismo registro**, donde la hora del incidente fue refinada conforme avanzaba la investigación policial. El sistema optó por agregar un nuevo registro en lugar de sobreescribir el existente, generando así el historial de cambios.
 
### Filas completamente idénticas
 
De los 18 casos duplicados, 2 (`JJ460760` y `JK173315`) son filas completamente idénticas en todos sus atributos, incluyendo `date_occurrence`. Estos representan errores de carga y deben eliminarse.
 
### Estrategia de limpieza
 
Dado que el registro más reciente representa la versión más actualizada y precisa del incidente, la estrategia de limpieza será **conservar únicamente el último registro por `case_number`**, ordenando por `date_occurrence` de forma descendente. Esto aplica tanto para los duplicados con horas distintas como para las filas completamente idénticas.
