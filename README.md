# Proyecto BD: Análisis de Criminalidad en Chicago (2001–Presente)

## Integrantes
* **Luis Fernando Reyes Altamirano** - Clave Única: 214734 - [LuisRyes](https://github.com/LuisRyes)
* **Ismael Cabrera Arroyo** - Clave Única: 217632 - [mayelmais](https://github.com/mayelmais)
* **Rodrigo Flores Covarrubias** - Clave Única: 217893 - [covaconv](https://github.com/covaconv)
* **Juan Pablo Padilla** -Clave Única: 213650 - [Padilla1111](https://github.com/Padilla1111)

## Introducción

Este proyecto analiza los incidentes criminales reportados en la ciudad de Chicago desde el año 2001 hasta la actualidad. La información es recolectada por el **Chicago Police Department** mediante el sistema CLEAR (*Citizen Law Enforcement Analysis and Reporting*) y se publica a través del portal de datos abiertos de la ciudad.

* **Propósito de recolección:** Promover la transparencia, la rendición de cuentas institucional y facilitar el análisis de seguridad pública para la toma de decisiones.
* **Frecuencia de actualización:** Diaria.

**Objetivo del Proyecto:**
El objetivo principal es transformar el conjunto de datos original de una estructura plana a un **esquema relacional robusto en PostgreSQL**. Se aplicarán procesos de limpieza, estandarización y normalización hasta **Cuarta Forma Normal (4NF)** para eliminar redundancias y asegurar la consistencia de la información. Posteriormente, se desarrollarán consultas SQL avanzadas —incluyendo agregaciones, funciones de ventana e índices— para analizar tendencias temporales, tasas de arresto y distribución geográfica de incidentes.

### Descripción Técnica y de Atributos

El dataset cuenta con más de 20 atributos que permiten un modelado relacional avanzado, facilitando el trabajo con integridad referencial, índices y optimización de consultas.

| Atributo | Descripción | Tipo |
| :--- | :--- | :--- |
| **ID** | Identificador único del registro de incidencia. | Numérico |
| **Case Number** | Número de registro oficial asignado al caso. | Texto |
| **Date** | Fecha y hora en la que ocurrió el incidente. | Temporal |
| **Block** | Dirección parcialmente anonimizada (nivel de cuadra). | Texto |
| **IUCR** | Código de Reporte de Crimen Uniforme de Illinois. | Texto |
| **Primary Type** | Clasificación principal del delito según el código IUCR. | Categórico |
| **Description** | Subclasificación detallada del tipo de delito. | Categórico |
| **Location Description** | Descripción del tipo de lugar donde ocurrió el evento. | Categórico |
| **Arrest** | Indica si el incidente resultó en un arresto (Booleano). | Categórico |
| **Domestic** | Indica si el incidente fue de violencia doméstica (Booleano). | Categórico |
| **Beat** | Área patrullada más pequeña de la policía de Chicago. | Numérico |
| **District** | Distrito policial donde ocurrió el incidente. | Numérico |
| **Ward** | Distrito electoral (City Council) donde ocurrió el incidente. | Numérico |
| **Community Area** | Área comunitaria de la ciudad de Chicago. | Numérico |
| **FBI Code** | Clasificación del crimen bajo estándares del FBI. | Categórico |
| **Year** | Año en que ocurrió el incidente. | Numérico |
| **Updated On** | Fecha de la última actualización del registro. | Temporal |
| **Latitude** | Coordenada de latitud de la ubicación exacta. | Numérico |
| **Longitude** | Coordenada de longitud de la ubicación exacta. | Numérico |
| **X Coordinate** | Coordenada X del sistema de proyección de la ciudad. | Numérico |
| **Y Coordinate** | Coordenada Y del sistema de proyección de la ciudad. | Numérico |

**Consideraciones Éticas:**
El análisis de datos de criminalidad conlleva una responsabilidad ética significativa, por lo que el equipo se adhiere a los siguientes criterios:
* **Privacidad y Anonimato:** Se respetará el anonimato de los datos a nivel de cuadra, evitando cruces de información que pudieran facilitar la reidentificación de víctimas o individuos involucrados.
* **Reconocimiento de Sesgos:** Se asume que los datos representan incidentes *reportados* y no la totalidad de los delitos ocurridos, considerando factores institucionales y de subdenuncia.
* **Prevención de la Estigmatización:** El análisis espacial se presentará con el contexto social necesario para evitar generalizaciones o prejuicios sobre zonas geográficas específicas.
* **Responsabilidad en el Uso:** Analizar datos de *open data* implica responsabilidad; aunque sean públicos, pueden permitir reidentificación o amplificar sesgos institucionales. El enfoque del proyecto es técnico y estructural, evaluando el daño potencial, ya que los datos abiertos no equivalen a un uso éticamente neutro.

## Fuente de datos

Para este proyecto se utilizan los datos proporcionados por el portal de datos de Chicago sobre crímenes. Se puede acceder a los datos en [este link](https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-Present/ijzp-q8t2).

* **Escala:** El conjunto de datos original cuenta con más de 7.9 millones de registros; para este proyecto se trabajará con un subconjunto superior a las 233,025 tuplas.

Las instrucciones de replicación del proyecto asumen que los datos se encuentran almacenados en formato `CSV` bajo el nombre `./data/raw_data.csv`.

## Documentación

### Estructura del repositorio
```text
├── README.md                                         <- Documentación para desarrolladores de este proyecto (i.e., reporte escrito)
├── data
│   ├── .gitignore
│   └── raw_data.csv                                  <- Datos en formato CSV como vienen de la fuente original
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
    └── 0N_analytical_queries.sql                     <- Consultas de interés sobre los datos normalizados (i.e., soporte de actividad E)
