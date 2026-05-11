/*
    Limpieza de Criminalidad Chicago
*/

-- Idempotencia: refresh destructivo del esquema cleaning
DROP SCHEMA IF EXISTS cleaning CASCADE;
CREATE SCHEMA cleaning;

-- Creación de tabla limpia excluyendo la columna redundante 'location' (Punto 6)
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

-- Uso de CTE  para numerar los registros duplicados
WITH RankedCrimes AS (
    SELECT 
        TRIM(UPPER(case_number)) AS case_number,
        
        -- Punto 3: Conversión de fecha a TIMESTAMP
        TO_TIMESTAMP(date_occurrence, 'MM/DD/YYYY HH12:MI:SS AM') AS incident_timestamp,
        
        TRIM(UPPER(block)) AS block,
        TRIM(iucr) AS iucr,
        TRIM(UPPER(primary_description)) AS primary_description,
        TRIM(UPPER(secondary_description)) AS secondary_description,
        
        -- Punto 2: Convertir strings vacíos a NULL en location_description
        NULLIF(TRIM(location_description), '') AS location_description,
        
        -- Punto 4: Convertir arrest y domestic a BOOLEAN
        CASE WHEN TRIM(UPPER(arrest)) = 'Y' THEN TRUE 
             WHEN TRIM(UPPER(arrest)) = 'N' THEN FALSE 
             ELSE NULL END AS arrest,
             
        CASE WHEN TRIM(UPPER(domestic)) = 'Y' THEN TRUE 
             WHEN TRIM(UPPER(domestic)) = 'N' THEN FALSE 
             ELSE NULL END AS domestic,
             
        -- Punto 5: Conversiones numéricas a INTEGER
        CAST(NULLIF(TRIM(beat), '') AS INTEGER) AS beat,
        CAST(NULLIF(TRIM(ward), '') AS INTEGER) AS ward,
        
        TRIM(UPPER(fbi_cd)) AS fbi_cd,
        
        -- Puntos 2 y 5: Strings vacíos a NULL y cast a FLOAT (DOUBLE PRECISION)
        CAST(NULLIF(TRIM(x_coordinate), '') AS DOUBLE PRECISION) AS x_coordinate,
        CAST(NULLIF(TRIM(y_coordinate), '') AS DOUBLE PRECISION) AS y_coordinate,
        CAST(NULLIF(TRIM(latitude), '') AS DOUBLE PRECISION) AS latitude,
        CAST(NULLIF(TRIM(longitude), '') AS DOUBLE PRECISION) AS longitude,
        
        -- Punto 1: Ventana para identificar el registro más reciente por case_number
        ROW_NUMBER() OVER(
            PARTITION BY TRIM(UPPER(case_number)) 
            ORDER BY TO_TIMESTAMP(date_occurrence, 'MM/DD/YYYY HH12:MI:SS AM') DESC
        ) as rn
    FROM raw.chicago_crimes
)

-- Inserción final filtrando solo el registro más reciente (donde rn = 1)
INSERT INTO cleaning.chicago_crimes
SELECT 
    case_number,
    incident_timestamp,
    block,
    iucr,
    primary_description,
    secondary_description,
    location_description,
    arrest,
    domestic,
    beat,
    ward,
    fbi_cd,
    x_coordinate,
    y_coordinate,
    latitude,
    longitude
FROM RankedCrimes
WHERE rn = 1;
