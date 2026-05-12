/*
    Limpieza de Criminalidad Chicago - Consolidado Definitivo
*/

-- Extensiones necesarias para funciones de similitud de texto
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

-- Idempotencia: refresh destructivo del esquema cleaning
DROP SCHEMA IF EXISTS cleaning CASCADE;
CREATE SCHEMA cleaning;

-- Creación de tabla limpia excluyendo la columna redundante 'location'
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
    beat INTEGER,
    ward INTEGER,
    fbi_cd TEXT,
    x_coordinate DOUBLE PRECISION,
    y_coordinate DOUBLE PRECISION,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION
);

-- Uso de CTE para numerar los registros duplicados y aplicar transformaciones
WITH RankedCrimes AS (
    SELECT 
        TRIM(UPPER(case_number)) AS case_number,
        
        -- CORRECCIÓN: Conversión flexible a TIMESTAMP en el SELECT
        CAST(NULLIF(TRIM(date_occurrence), '') AS TIMESTAMP) AS incident_timestamp,
        
        TRIM(UPPER(block)) AS block,
        TRIM(iucr) AS iucr,
        TRIM(UPPER(primary_description)) AS primary_description,
        TRIM(UPPER(secondary_description)) AS secondary_description,
        
        NULLIF(TRIM(location_description), '') AS location_description,
        
        CASE WHEN TRIM(UPPER(arrest)) = 'Y' THEN TRUE 
             WHEN TRIM(UPPER(arrest)) = 'N' THEN FALSE 
             ELSE NULL END AS arrest,
             
        CASE WHEN TRIM(UPPER(domestic)) = 'Y' THEN TRUE 
             WHEN TRIM(UPPER(domestic)) = 'N' THEN FALSE 
             ELSE NULL END AS domestic,
             
        CAST(NULLIF(TRIM(beat), '') AS INTEGER) AS beat,
        CAST(NULLIF(TRIM(ward), '') AS INTEGER) AS ward,
        
        TRIM(UPPER(fbi_cd)) AS fbi_cd,
        
        CAST(NULLIF(TRIM(x_coordinate), '') AS DOUBLE PRECISION) AS x_coordinate,
        CAST(NULLIF(TRIM(y_coordinate), '') AS DOUBLE PRECISION) AS y_coordinate,
        CAST(NULLIF(TRIM(latitude), '') AS DOUBLE PRECISION) AS latitude,
        CAST(NULLIF(TRIM(longitude), '') AS DOUBLE PRECISION) AS longitude,
        
        -- CORRECCIÓN: Conversión flexible a TIMESTAMP en la ventana
        ROW_NUMBER() OVER(
            PARTITION BY TRIM(UPPER(case_number)) 
            ORDER BY CAST(NULLIF(TRIM(date_occurrence), '') AS TIMESTAMP) DESC
        ) as rn
    FROM raw.chicago_crimes
)

-- Inserción final filtrando solo el registro más reciente
INSERT INTO cleaning.chicago_crimes
SELECT 
    case_number, incident_timestamp, block, iucr, 
    primary_description, secondary_description, location_description, 
    arrest, domestic, beat, ward, fbi_cd, 
    x_coordinate, y_coordinate, latitude, longitude
FROM RankedCrimes
WHERE rn = 1;


/*
    Estandarización Avanzada y Consolidación
*/

-- 1. Eliminar puntos o caracteres innecesarios en locaciones
-- CORRECCIÓN: Blindaje contra nulos para evitar errores en Regex
UPDATE cleaning.chicago_crimes
SET location_description = REGEXP_REPLACE(location_description, '[.]', '', 'g')
WHERE location_description IS NOT NULL;

-- 2. Consolidar variantes relacionadas con STREET
UPDATE cleaning.chicago_crimes
SET location_description = 'STREET'
WHERE location_description LIKE '%STREET%';

-- 3. Consolidar variantes relacionadas con SIDEWALK
UPDATE cleaning.chicago_crimes
SET location_description = 'SIDEWALK'
WHERE location_description LIKE '%SIDEWALK%';

-- 4. Corrección controlada de posibles errores de dedo (Levenshtein)
UPDATE cleaning.chicago_crimes
SET primary_description = 'HOMICIDE'
WHERE primary_description IS NOT NULL
  AND LEVENSHTEIN('HOMICIDE', primary_description) BETWEEN 1 AND 2;

-- 5. CORRECCIÓN RECUPERADA: Imputación de códigos FBI faltantes basados en el mismo IUCR
UPDATE cleaning.chicago_crimes AS c1
SET fbi_cd = c2.fbi_cd
FROM cleaning.chicago_crimes AS c2
WHERE c1.iucr = c2.iucr 
  AND c1.fbi_cd IS NULL 
  AND c2.fbi_cd IS NOT NULL;

-- 6. Agrupación de categorías poco frecuentes (Outliers de locación)
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
