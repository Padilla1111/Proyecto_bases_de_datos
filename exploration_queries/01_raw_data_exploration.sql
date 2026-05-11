-- =============================================================================
-- ANÁLISIS EXPLORATORIO DE DATOS
-- Dataset: Chicago Crimes (raw.chicago_crimes)
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. CONTEO TOTAL DE TUPLAS
-- -----------------------------------------------------------------------------

SELECT COUNT(*) AS total_tuplas
FROM raw.chicago_crimes;


-- -----------------------------------------------------------------------------
-- 2. VALORES NULOS (NULL)
--    Ninguna columna debería tener NULLs, pero se verifica por completitud.
-- -----------------------------------------------------------------------------

SELECT 
    COUNT(*) FILTER (WHERE case_number IS NULL) AS nulos_case_number,
    COUNT(*) FILTER (WHERE date_occurrence IS NULL) AS nulos_date_occurrence,
    COUNT(*) FILTER (WHERE block IS NULL) AS nulos_block,
    COUNT(*) FILTER (WHERE iucr IS NULL) AS nulos_iucr,
    COUNT(*) FILTER (WHERE primary_description IS NULL) AS nulos_primary_description,
    COUNT(*) FILTER (WHERE secondary_description IS NULL) AS nulos_secondary_description,
    COUNT(*) FILTER (WHERE location_description IS NULL) AS nulos_location_description,
    COUNT(*) FILTER (WHERE arrest IS NULL) AS nulos_arrest,
    COUNT(*) FILTER (WHERE domestic IS NULL) AS nulos_domestic,
    COUNT(*) FILTER (WHERE beat IS NULL) AS nulos_beat,
    COUNT(*) FILTER (WHERE ward IS NULL) AS nulos_ward,
    COUNT(*) FILTER (WHERE fbi_cd IS NULL) AS nulos_fbi_cd,
    COUNT(*) FILTER (WHERE x_coordinate IS NULL) AS nulos_x_coordinate,
    COUNT(*) FILTER (WHERE y_coordinate IS NULL) AS nulos_y_coordinate,
    COUNT(*) FILTER (WHERE latitude IS NULL) AS nulos_latitude,
    COUNT(*) FILTER (WHERE longitude IS NULL) AS nulos_longitude,
    COUNT(*) FILTER (WHERE location IS NULL) AS nulos_location
FROM raw.chicago_crimes;


-- -----------------------------------------------------------------------------
-- 3. VALORES VACÍOS ('')
--    El dataset no usa NULL para datos faltantes sino strings vacíos.
--    Se identifican las columnas afectadas y su magnitud.
-- -----------------------------------------------------------------------------

SELECT 
    COUNT(*) FILTER (WHERE block = '') AS vacios_block,
    COUNT(*) FILTER (WHERE iucr = '') AS vacios_iucr,
    COUNT(*) FILTER (WHERE primary_description = '') AS vacios_primary_description,
    COUNT(*) FILTER (WHERE secondary_description = '') AS vacios_secondary_description,
    COUNT(*) FILTER (WHERE location_description = '') AS vacios_location_description,
    COUNT(*) FILTER (WHERE arrest = '') AS vacios_arrest,
    COUNT(*) FILTER (WHERE domestic = '') AS vacios_domestic,
    COUNT(*) FILTER (WHERE beat = '') AS vacios_beat,
    COUNT(*) FILTER (WHERE ward = '') AS vacios_ward,
    COUNT(*) FILTER (WHERE fbi_cd = '') AS vacios_fbi_cd,
    COUNT(*) FILTER (WHERE x_coordinate = '') AS vacios_x_coordinate,
    COUNT(*) FILTER (WHERE y_coordinate = '') AS vacios_y_coordinate,
    COUNT(*) FILTER (WHERE latitude = '') AS vacios_latitude,
    COUNT(*) FILTER (WHERE longitude = '') AS vacios_longitude,
    COUNT(*) FILTER (WHERE location = '') AS vacios_location
FROM raw.chicago_crimes;


-- -----------------------------------------------------------------------------
-- 4. CARDINALIDAD DE COLUMNAS
--    Conteo de valores únicos por columna. Permite identificar llaves primarias
--    candidatas y confirmar la naturaleza categórica de los atributos.
-- -----------------------------------------------------------------------------

SELECT 
    COUNT(DISTINCT case_number) AS unicos_case_number,
    COUNT(DISTINCT date_occurrence) AS unicos_date_occurrence,
    COUNT(DISTINCT block) AS unicos_block,
    COUNT(DISTINCT iucr) AS unicos_iucr,
    COUNT(DISTINCT primary_description) AS unicos_primary_description,
    COUNT(DISTINCT secondary_description) AS unicos_secondary_description,
    COUNT(DISTINCT location_description) AS unicos_location_description,
    COUNT(DISTINCT arrest) AS unicos_arrest,
    COUNT(DISTINCT domestic) AS unicos_domestic,
    COUNT(DISTINCT beat) AS unicos_beat,
    COUNT(DISTINCT ward) AS unicos_ward,
    COUNT(DISTINCT fbi_cd) AS unicos_fbi_cd,
    COUNT(DISTINCT x_coordinate) AS unicos_x_coordinate,
    COUNT(DISTINCT y_coordinate) AS unicos_y_coordinate,
    COUNT(DISTINCT latitude) AS unicos_latitude,
    COUNT(DISTINCT longitude) AS unicos_longitude,
    COUNT(DISTINCT location) AS unicos_location
FROM raw.chicago_crimes;


-- -----------------------------------------------------------------------------
-- 5. ANÁLISIS DE DUPLICADOS
--    Se detecta que case_number no es completamente único. Se investigan
--    los duplicados para determinar si son errores de carga o actualizaciones.
-- -----------------------------------------------------------------------------

-- 5a. Identificar qué case_numbers están repetidos y cuántas veces
SELECT case_number, COUNT(*) AS apariciones
FROM raw.chicago_crimes
GROUP BY case_number
HAVING COUNT(*) > 1
ORDER BY apariciones DESC;

-- 5b. Inspeccionar todos los registros duplicados en detalle
--     Resultado: todos los duplicados son homicidios y solo difieren en date_occurrence,
--     lo que sugiere actualizaciones progresivas del registro, no errores.
SELECT case_number, block, iucr, primary_description, secondary_description, 
       location_description, arrest, domestic, beat, ward, fbi_cd, 
       x_coordinate, y_coordinate, latitude, longitude, location, date_occurrence
FROM raw.chicago_crimes
WHERE case_number IN ('JJ384488','JJ293685','JJ309322','JJ249047','JJ318710',
                      'JJ261204','JJ302653','JK173315','JJ438632','JK200026',
                      'JK221489','JK137074','JK174465','JJ482411','JK190537',
                      'JJ460760','JK193204','JK232539')
ORDER BY case_number, date_occurrence;

-- 5c. Verificar si existen filas completamente idénticas (mismo case_number Y misma hora)
SELECT *, COUNT(*)
FROM raw.chicago_crimes
GROUP BY case_number, date_occurrence, block, iucr, primary_description, 
         secondary_description, location_description, arrest, domestic, 
         beat, ward, fbi_cd, x_coordinate, y_coordinate, latitude, longitude, location
HAVING COUNT(*) > 1;


-- -----------------------------------------------------------------------------
-- 6. RANGO TEMPORAL
--    Se castea date_occurrence a TIMESTAMP para obtener min y max correctos.
--    El formato original es MM/DD/YYYY HH:MI:SS AM/PM.
-- -----------------------------------------------------------------------------

SELECT 
    MIN(TO_TIMESTAMP(date_occurrence, 'MM/DD/YYYY HH:MI:SS AM')) AS fecha_minima,
    MAX(TO_TIMESTAMP(date_occurrence, 'MM/DD/YYYY HH:MI:SS AM')) AS fecha_maxima
FROM raw.chicago_crimes;


-- -----------------------------------------------------------------------------
-- 7. RANGO GEOGRÁFICO
--    Se excluyen los registros con coordenadas vacías para el cálculo.
--    Se verifica que los valores estén dentro del rango geográfico de Chicago.
-- -----------------------------------------------------------------------------

SELECT 
    MIN(latitude) AS lat_min, 
    MAX(latitude) AS lat_max, 
    MIN(longitude) AS long_min, 
    MAX(longitude) AS long_max
FROM raw.chicago_crimes
WHERE latitude != '' AND longitude != '';


-- -----------------------------------------------------------------------------
-- 8. VALORES DISTINTOS EN ATRIBUTOS CATEGÓRICOS
--    Se listan los valores únicos de cada columna categórica para verificar
--    consistencia y detectar valores inesperados o errores de captura.
-- -----------------------------------------------------------------------------

SELECT DISTINCT iucr FROM raw.chicago_crimes ORDER BY iucr;
SELECT DISTINCT primary_description FROM raw.chicago_crimes ORDER BY primary_description;
SELECT DISTINCT secondary_description FROM raw.chicago_crimes ORDER BY secondary_description;
SELECT DISTINCT location_description FROM raw.chicago_crimes ORDER BY location_description;
SELECT DISTINCT arrest FROM raw.chicago_crimes ORDER BY arrest;
SELECT DISTINCT domestic FROM raw.chicago_crimes ORDER BY domestic;
SELECT DISTINCT beat FROM raw.chicago_crimes ORDER BY beat;
SELECT DISTINCT ward FROM raw.chicago_crimes ORDER BY ward;
SELECT DISTINCT fbi_cd FROM raw.chicago_crimes ORDER BY fbi_cd;


-- -----------------------------------------------------------------------------
-- 9. CONTEO DE TUPLAS POR CATEGORÍA
--    Distribución de registros por cada atributo categórico.
--    Permite identificar categorías dominantes y outliers.
-- -----------------------------------------------------------------------------

SELECT primary_description, COUNT(*) AS conteo
FROM raw.chicago_crimes
GROUP BY primary_description
ORDER BY conteo DESC;

SELECT secondary_description, COUNT(*) AS conteo
FROM raw.chicago_crimes
GROUP BY secondary_description
ORDER BY conteo DESC;

SELECT iucr, COUNT(*) AS conteo
FROM raw.chicago_crimes
GROUP BY iucr
ORDER BY conteo DESC;

SELECT fbi_cd, COUNT(*) AS conteo
FROM raw.chicago_crimes
GROUP BY fbi_cd
ORDER BY conteo DESC;

SELECT location_description, COUNT(*) AS conteo
FROM raw.chicago_crimes
GROUP BY location_description
ORDER BY conteo DESC;

SELECT beat, COUNT(*) AS conteo
FROM raw.chicago_crimes
GROUP BY beat
ORDER BY conteo DESC;

SELECT ward, COUNT(*) AS conteo
FROM raw.chicago_crimes
GROUP BY ward
ORDER BY conteo DESC;

SELECT arrest, COUNT(*) AS conteo
FROM raw.chicago_crimes
GROUP BY arrest
ORDER BY conteo DESC;

SELECT domestic, COUNT(*) AS conteo
FROM raw.chicago_crimes
GROUP BY domestic
ORDER BY conteo DESC;
