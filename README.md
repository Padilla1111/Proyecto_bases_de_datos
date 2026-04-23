# Análisis de Criminalidad en Chicago (2001–Presente)

## A) Introducción al Conjunto de Datos

Este proyecto analiza los incidentes criminales reportados en la ciudad de Chicago desde el año 2001 hasta la actualidad. La información es recolectada por el **Chicago Police Department** mediante el sistema CLEAR (*Citizen Law Enforcement Analysis and Reporting*) y se publica a través del portal de datos abiertos de la ciudad.

* **Propósito de recolección:** Promover la transparencia, la rendición de cuentas institucional y facilitar el análisis de seguridad pública para la toma de decisiones.
* **Fuente de Datos (Replicación):** Los datos pueden obtenerse en el [Chicago Data Portal - Crimes 2001 to Present](https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-Present/ijzp-q8t2).
* **Frecuencia de actualización:** Diaria.
* **Escala:** El conjunto de datos original cuenta con más de 7.9 millones de registros; para este proyecto se trabajará con un subconjunto superior a las 233,025 tuplas.

---

## B) Descripción Técnica y Estructura

El dataset cuenta con más de 20 atributos que permiten un modelado relacional avanzado, facilitando el trabajo con integridad referencial, índices y optimización de consultas.

### Clasificación y Descripción de Atributos

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
| **Beat / District** | Áreas patrulladas y distritos policiales. | Numérico |
| **Ward / Community Area** | Divisiones electorales y áreas comunitarias. | Numérico |
| **FBI Code** | Clasificación del crimen bajo estándares del FBI. | Categórico |
| **Updated On** | Fecha de la última actualización del registro. | Temporal |
| **Latitude / Longitude** | Ubicación geográfica exacta del incidente. | Numérico |

---

## C) Objetivo del Proyecto

El objetivo principal es transformar el conjunto de datos original de una estructura plana a un **esquema relacional robusto en PostgreSQL**. Se aplicarán procesos de limpieza, estandarización y normalización hasta **Cuarta Forma Normal (4NF)** para eliminar redundancias y asegurar la consistencia de la información.

Posteriormente, se desarrollarán consultas SQL avanzadas —incluyendo agregaciones, funciones de ventana e índices— para analizar tendencias temporales, tasas de arresto y distribución geográfica de incidentes.

---

## D) Consideraciones Éticas

El análisis de datos de criminalidad conlleva una responsabilidad ética significativa, por lo que el equipo se adhiere a los siguientes criterios:

* **Privacidad y Anonimato:** Se respetará el anonimato de los datos a nivel de cuadra, evitando cruces de información que pudieran facilitar la reidentificación de víctimas o individuos involucrados.
* **Reconocimiento de Sesgos:** Se asume que los datos representan incidentes *reportados* y no la totalidad de los delitos ocurridos, considerando factores institucionales y de subdenuncia.
* **Prevención de la Estigmatización:** El análisis espacial se presentará con el contexto social necesario para evitar generalizaciones o prejuicios sobre zonas geográficas específicas.
* **Responsabilidad en el Uso:** El enfoque del proyecto es técnico y estructural; el uso de datos abiertos no exime al equipo de evaluar el daño potencial de interpretaciones erróneas que pudieran amplificar sesgos existentes.
