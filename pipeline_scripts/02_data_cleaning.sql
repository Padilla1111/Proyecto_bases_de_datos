/*
    Limpieza de Criminalidad Chicago
*/

-- Extensiones necesarias para funciones de similitud de texto
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

-- Idempotencia: refresh destructivo del esquema cleaning
DROP SCHEMA IF EXISTS cleaning CASCADE;
CREATE SCHEMA cleaning;

-- Creación de tabla limpia con tipos de datos finales
CREATE TABLE cleaning.chicago_crimes (
    case_number TEXT,
    incident_timestamp TIMESTAMP,
    block TEXT,
    iucr TEXT,
    primary_description TEXT,
    secondary_description TEXT,
    location_description TEXT,
    arrest BOOLEAN,
    domestic BOOLEAN,
    beat TEXT,
    ward INTEGER,
    fbi_cd TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION
);

-- Carga inicial con transformaciones básicas y eliminación de duplicados exactos
INSERT INTO cleaning.chicago_crimes
SELECT DISTINCT
    TRIM(UPPER(case_number)),
    TO_TIMESTAMP(date_occurrence, 'MM/DD/YYYY HH12:MI:SS AM'),
    TRIM(UPPER(block)),
    TRIM(iucr), -- Los códigos IUCR son relativamente estables
    TRIM(UPPER(primary_description)),
    TRIM(UPPER(secondary_description)),
    TRIM(UPPER(location_description)),

    -- Conversión de indicadores Y/N a BOOLEAN
    CASE
        WHEN arrest = 'Y' THEN TRUE
        WHEN arrest = 'N' THEN FALSE
        ELSE NULL
    END,

    CASE
        WHEN domestic = 'Y' THEN TRUE
        WHEN domestic = 'N' THEN FALSE
        ELSE NULL
    END,

    TRIM(beat),

    -- Conversión de strings vacíos a NULL antes de castear
    CAST(NULLIF(TRIM(ward), '') AS INTEGER),

    TRIM(UPPER(fbi_cd)),

    CAST(NULLIF(TRIM(latitude), '') AS DOUBLE PRECISION),
    CAST(NULLIF(TRIM(longitude), '') AS DOUBLE PRECISION)

FROM raw.chicago_crimes;

/*
    Estandarización de Lugares de Crimen
*/

-- 1. Eliminar puntos o caracteres innecesarios
UPDATE cleaning.chicago_crimes
SET location_description = REGEXP_REPLACE(location_description, '[.]', '', 'g');

-- 2. Consolidar variantes relacionadas con STREET
UPDATE cleaning.chicago_crimes
SET location_description = 'STREET'
WHERE location_description LIKE '%STREET%';

-- 3. Consolidar variantes relacionadas con SIDEWALK
UPDATE cleaning.chicago_crimes
SET location_description = 'SIDEWALK'
WHERE location_description LIKE '%SIDEWALK%';

-- 4. Corrección controlada de posibles errores de dedo
-- Ejemplo: HOMICID -> HOMICIDE
UPDATE cleaning.chicago_crimes
SET primary_description = 'HOMICIDE'
WHERE primary_description IS NOT NULL
  AND LEVENSHTEIN('HOMICIDE', primary_description) BETWEEN 1 AND 2;

-- 5. Agrupación de categorías poco frecuentes
-- Las locaciones con menos de 5 registros se agrupan como OTHER
WITH locations_with_5_or_more AS (
    SELECT location_description
    FROM cleaning.chicago_crimes
    WHERE location_description IS NOT NULL
    GROUP BY location_description
    HAVING COUNT(*) >= 5
)

UPDATE cleaning.chicago_crimes
SET location_description = 'OTHER (LOW FREQUENCY)'
WHERE location_description NOT IN (
    SELECT location_description
    FROM locations_with_5_or_more
)
OR location_description IS NULL;
