/*
    Limpieza de Criminalidad Chicago
*/

-- Extensiones (por si necesitamos LEVENSHTEIN en descripciones)
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

-- Idempotencia: refresh destructivo del esquema
DROP SCHEMA IF EXISTS cleaning CASCADE;
CREATE SCHEMA cleaning;

-- Creación de la tabla limpia con tipos de datos finales
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

-- Carga inicial con transformación básica (Estandarizar de texto)
INSERT INTO cleaning.chicago_crimes
SELECT 
    TRIM(UPPER(case_number)),
    TO_TIMESTAMP(date_occurrence, 'MM/DD/YYYY HH12:MI:SS AM'),
    TRIM(UPPER(block)),
    TRIM(iucr), -- Los códigos IUCR suelen ser fijos, por eso solo quitamos espacios
    TRIM(UPPER(primary_description)),
    TRIM(UPPER(secondary_description)),
    TRIM(UPPER(location_description)),
    CASE WHEN arrest = 'Y' THEN TRUE ELSE FALSE END,
    CASE WHEN domestic = 'Y' THEN TRUE ELSE FALSE END,
    TRIM(beat),
    CAST(NULLIF(TRIM(ward), '') AS INTEGER),
    TRIM(UPPER(fbi_cd)),
    CAST(NULLIF(latitude, '') AS DOUBLE PRECISION),
    CAST(NULLIF(longitude, '') AS DOUBLE PRECISION)
FROM raw.chicago_crimes;

/*
    Estandarización de Lugares de Crimen
*/

-- 1. Eliminar caracteres especiales o puntos extras en descripciones de ubicación
UPDATE cleaning.chicago_crimes
SET location_description = REGEXP_REPLACE(location_description, '[.]', '', 'g');

-- 2. Consolidar categorías similares (ejemplo: simplificar variantes de "STREET")
UPDATE cleaning.chicago_crimes
SET location_description = 'STREET'
WHERE location_description LIKE '%STREET%' 
   OR location_description LIKE '%SIDEWALK%';

-- 3. Uso de Distancia de Levenshtein (por si hubiera errores de dedo en crímenes raros)
-- Esto es útil para Primary Description si hubiera "HOMICIDE" vs "HOMICID"
UPDATE cleaning.chicago_crimes
SET primary_description = 'HOMICIDE'
WHERE LEVENSHTEIN('HOMICIDE', primary_description) BETWEEN 1 AND 2;

-- 4. Agrupación de "Otros" para locaciones muy poco frecuentes (menos de 5 casos)
WITH locations_with_5_or_more AS (
    SELECT location_description
    FROM cleaning.chicago_crimes
    GROUP BY location_description
    HAVING COUNT(*) >= 5
)
UPDATE cleaning.chicago_crimes
SET location_description = 'OTHER (LOW FREQUENCY)'
WHERE location_description NOT IN (SELECT location_description FROM locations_with_5_or_more)
   OR location_description IS NULL;