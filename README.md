# Proyecto BD: Análisis de Criminalidad en Chicago (Último Año)

## Integrantes
* **Luis Fernando Reyes Altamirano** - Clave Única: 214734 - [LuisRyes](https://github.com/LuisRyes)
* **Ismael Cabrera Arroyo** - Clave Única: 217632 - [mayelmais](https://github.com/mayelmais)
* **Rodrigo Flores Covarrubias** - Clave Única: 217893 - [covaconv](https://github.com/covaconv)
* **Juan Pablo Padilla** - Clave Única: 213650 - [Padilla1111](https://github.com/Padilla1111)

## Introducción

Este proyecto analiza los incidentes criminales reportados en la ciudad de Chicago. Originalmente enfocado en el histórico desde 2001, para fines de replicación y eficiencia técnica se utiliza el dataset de incidentes del último año. La información es recolectada por el **Chicago Police Department** mediante el sistema CLEAR (*Citizen Law Enforcement Analysis and Reporting*) y se publica a través del **Chicago Data Portal**.

* **Propósito de recolección:** Promover la transparencia, la rendición de cuentas institucional y facilitar el análisis de seguridad pública para la toma de decisiones.
* **Frecuencia de actualización:** Diaria.

**Objetivo del Proyecto:**
El objetivo principal es transformar el conjunto de datos original de una estructura plana a un **esquema relacional robusto en PostgreSQL**. Se aplicarán procesos de limpieza, estandarización y normalización hasta **Cuarta Forma Normal (4NF)** para eliminar redundancias y asegurar la consistencia de la información. Posteriormente, se desarrollarán consultas SQL avanzadas —incluyendo agregaciones, funciones de ventana e índices— para analizar tendencias temporales, tasas de arresto y distribución geográfica de incidentes.

### Descripción Técnica y de Atributos

El dataset seleccionado cuenta con la variedad necesaria de atributos para un modelado relacional avanzado, facilitando el trabajo con integridad referencial, índices y optimización de consultas.

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

* **Escala:** El dataset contiene aproximadamente 200,000 registros, lo que cumple con el requisito de carga mínima (>5,000 tuplas).

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
    └── 0N_analytical_queries.sql                     <- Consultas de interés sobre los datos normalizados (i.e., soporte de actividad 
```

# Carga inicial y análisis preliminar

## Carga inicial

En primer lugar se deberá crear una base de datos exclusiva para este proyecto. Para ello se puede ejecutar el siguiente comando en `psql`:

```sql
CREATE DATABASE crimes_chicago;
```
Posteriormente, debemos conectarnos a dicha base de datos empleando:

```bash
\c crime_chicago
```
Finalmente, para cargar los datos en bruto se debe ejecutar el siguiente comando en una sesión de línea de comandos `psql`:
(Nota: esto es la ruta donde tu guardaste el archivo, depende de donde lo guardaste)
```bash
\i pipeline_scripts/01_raw_data_schema_creation_and_load.sql
```
