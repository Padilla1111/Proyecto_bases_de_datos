# Análisis de Criminalidad en Chicago (2001–Presente)

## Introducción al Conjunto de Datos

Este proyecto analiza los incidentes criminales reportados en la ciudad de Chicago desde 2001 hasta la fecha. Los datos son recopilados por el **Chicago Police Department** mediante el sistema CLEAR (Citizen Law Enforcement Analysis and Reporting) y se publican a través del **Chicago Data Portal**, con actualizaciones diarias. Su finalidad institucional es promover transparencia, rendición de cuentas y análisis de seguridad pública.

Se trata de un conjunto de datos público, de gran escala y con estructura adecuada para fines académicos y técnicos.


---

## Descripción Técnica y Estructura

El dataset cumple con los requisitos del proyecto (más de 233,025 registros y más de 20 atributos) y presenta variedad suficiente para modelado relacional avanzado.

### Clasificación de atributos

* **Numéricos:** ID, Beat, District, Ward, Community Area, Year, X Coordinate, Y Coordinate, Latitude, Longitude.
* **Categóricos:** Primary Type, Description, Location Description, Arrest (booleano), Domestic (booleano), FBI Code.
* **Texto:** Case Number, Block, IUCR.
* **Temporales:** Date (fecha del incidente), Updated On (última actualización).

Esta diversidad permite trabajar con integridad referencial, claves foráneas, índices compuestos y optimización de consultas.

---

## Objetivo del Proyecto

El objetivo es transformar el conjunto de datos original (estructura plana) en un esquema relacional robusto implementado en PostgreSQL, aplicando procesos de limpieza, estandarización y normalización hasta Cuarta Forma Normal (4NF) para reducir redundancias y asegurar consistencia.

Posteriormente, se desarrollarán consultas SQL avanzadas —incluyendo agregaciones, funciones de ventana e índices optimizados— para analizar tendencias temporales, tasas de arresto y distribución geográfica de incidentes, sentando bases estructurales para posibles extensiones analíticas futuras.

---

## Consideraciones Éticas

El análisis de datos de criminalidad requiere criterios estrictos:

* **Privacidad:** Aunque los registros están anonimizados a nivel de cuadra, no se realizarán cruces que permitan la identificación indirecta de individuos.
* **Contexto estadístico:** Los datos representan incidentes reportados, no la totalidad de delitos ocurridos, debido a la subdenuncia.
* **Prevención de estigmatización:** El análisis espacial debe considerar factores como densidad poblacional y presencia policial para evitar conclusiones simplistas sobre determinadas zonas.

El enfoque del proyecto es técnico y estructural, no predictivo ni orientado a clasificación de individuos o comunidades.
sos individuales.
- ¿Qué consideraciones éticas conlleva el análisis y explotación de dichos datos?: Analizar datos del Chicago Data Portal implica responsabilidad ética porque, aunque sean públicos, pueden permitir reidentificación, amplificar sesgos institucionales (por ejemplo en datasets de crimen), estigmatizar comunidades o generar impactos negativos si se usan con fines comerciales o predictivos sin contexto, transparencia y evaluación del daño potencial; open data no equivale a uso éticamente neutro.
