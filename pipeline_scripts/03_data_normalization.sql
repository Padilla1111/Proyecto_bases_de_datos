-- =============================================================================
-- Actividad D: Normalización a Cuarta Forma Normal (4FN)
-- Proyecto BD: Análisis de Criminalidad en Chicago (Último Año)
-- =============================================================================
-- Este script transforma el schema `cleaning` en un diseño relacional
-- normalizado hasta 4FN. Todos los catálogos se derivan directamente de
-- los datos limpios mediante SELECT DISTINCT — sin archivos externos ni
-- valores hardcodeados.
--
-- Prerrequisito: haber ejecutado 02_data_cleaning.sql
--
-- Ejecución desde la raíz del proyecto:
--   psql -U [tuUsuario] -d crimenes -f pipeline_scripts/03_data_normalization.sql
-- =============================================================================


-- =============================================================================
-- Análisis de Dependencias Funcionales y Multivaluadas
-- =============================================================================
--
-- Clave primaria candidata de la relación original: case_number
--
-- Dependencias funcionales no triviales identificadas:
--
--   (1) case_number → date_occurrence, block, arrest, domestic,
--                     x_coordinate, y_coordinate, latitude, longitude,
--                     beat, ward, iucr, fbi_cd, location_description
--
--   (2) iucr → primary_description, secondary_description, index_code, active
--       Los códigos IUCR tienen descripciones predefinidas, confirmado por
--       la baja cardinalidad frente a los ~232,000 registros.
--
--   (3) iucr → fbi_cd
--       Dependencia transitiva: violada si fbi_cd permanece en incident.
--
--   (4) fbi_cd (sin atributos adicionales en este diseño simplificado)
--       Se modela solo el código, no las descripciones.
--
--   (5) beat (sin atributos adicionales)
--
--   (6) ward (sin atributos adicionales)
--
--   (7) location_description (sin atributos adicionales)
--
-- Dependencias Multivaluadas: No se identificaron MVDs independientes.
-- Cada incidente registra exactamente un valor de iucr, beat, ward y
-- location_description. Alcanzar 4FN equivale a eliminar todas las
-- dependencias transitivas.
--
-- Relvars resultantes (6 tablas, todas derivadas del cleaning):
--   normalization.beat            PK: beat_id,  AK: beat
--   normalization.ward            PK: ward_id
--   normalization.fbi_code        PK: fbi_cd
--   normalization.iucr            PK: iucr_id,  AK: iucr
--   normalization.location_type   PK: location_type_id, AK: location_description
--   normalization.incident        PK: incident_id, AK: case_number
-- =============================================================================


-- =============================================================================
-- 0. Preparación del schema (refresh destructivo — garantiza idempotencia)
-- =============================================================================

DROP SCHEMA IF EXISTS normalization CASCADE;
CREATE SCHEMA normalization;


-- =============================================================================
-- Tablas de Referencia (Derivadas 100% del cleaning via SELECT DISTINCT)
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. normalization.beat
--    Catálogo de beats extraído directamente de los datos limpios.
--    FD: beat_id → beat (1:1)
-- -----------------------------------------------------------------------------

CREATE TABLE normalization.beat (
    beat_id SERIAL      PRIMARY KEY,
    beat    VARCHAR(10) NOT NULL UNIQUE
);

INSERT INTO normalization.beat (beat)
SELECT DISTINCT beat::VARCHAR
FROM cleaning.chicago_crimes
WHERE beat IS NOT NULL
ORDER BY 1;


-- -----------------------------------------------------------------------------
-- 2. normalization.ward
--    Catálogo de wards extraído directamente de los datos limpios.
--    FD: ward_id → (sin atributos adicionales)
-- -----------------------------------------------------------------------------

CREATE TABLE normalization.ward (
    ward_id SMALLINT PRIMARY KEY
);

INSERT INTO normalization.ward (ward_id)
SELECT DISTINCT ward::SMALLINT
FROM cleaning.chicago_crimes
WHERE ward IS NOT NULL
ORDER BY 1;


-- -----------------------------------------------------------------------------
-- 3. normalization.fbi_code
--    Catálogo de códigos FBI extraído directamente de los datos limpios.
--    FD: fbi_cd → (sin atributos adicionales)
-- -----------------------------------------------------------------------------

CREATE TABLE normalization.fbi_code (
    fbi_cd VARCHAR(10) PRIMARY KEY
);

INSERT INTO normalization.fbi_code (fbi_cd)
SELECT DISTINCT TRIM(fbi_cd)
FROM cleaning.chicago_crimes
WHERE fbi_cd IS NOT NULL
  AND TRIM(fbi_cd) <> ''
ORDER BY 1;


-- -----------------------------------------------------------------------------
-- 4. normalization.iucr
--    Catálogo de códigos IUCR con descripciones extraído del cleaning.
--    FD: iucr → primary_description, secondary_description, index_code, active, fbi_cd
--    Nota: fbi_cd aquí elimina la dependencia transitiva
--          case_number → iucr → fbi_cd
-- -----------------------------------------------------------------------------

CREATE TABLE normalization.iucr (
    iucr_id               SERIAL       PRIMARY KEY,
    iucr                  VARCHAR(10)  NOT NULL UNIQUE,
    primary_description   VARCHAR(200),
    secondary_description VARCHAR(200),
    index_code            VARCHAR(5),
    active                BOOLEAN,
    fbi_cd                VARCHAR(10)  REFERENCES normalization.fbi_code(fbi_cd)
);

INSERT INTO normalization.iucr (iucr, primary_description, secondary_description, index_code, active, fbi_cd)
SELECT DISTINCT ON (TRIM(c.iucr))
    TRIM(c.iucr),
    TRIM(c.primary_description),
    CASE WHEN TRIM(c.secondary_description) <> '' THEN TRIM(c.secondary_description) ELSE NULL END,
    NULL::VARCHAR(5),
    NULL::BOOLEAN,
    CASE WHEN TRIM(c.fbi_cd) <> '' THEN TRIM(c.fbi_cd) ELSE NULL END
FROM cleaning.chicago_crimes c
WHERE c.iucr IS NOT NULL 
  AND TRIM(c.iucr) <> ''
ORDER BY TRIM(c.iucr), c.incident_timestamp DESC;


-- -----------------------------------------------------------------------------
-- 5. normalization.location_type
--    Catálogo de tipos de ubicación extraído directamente del cleaning.
--    FD: location_type_id → location_description
-- -----------------------------------------------------------------------------

CREATE TABLE normalization.location_type (
    location_type_id     SERIAL       PRIMARY KEY,
    location_description VARCHAR(200) NOT NULL UNIQUE
);

INSERT INTO normalization.location_type (location_description)
SELECT DISTINCT location_description
FROM cleaning.chicago_crimes
WHERE location_description IS NOT NULL
  AND TRIM(location_description) <> ''
ORDER BY 1;


-- =============================================================================
-- Tabla Principal de Hechos
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 6. normalization.incident
--    FD: case_number → todos los atributos directos del incidente
--    Fuente: cleaning.chicago_crimes
--    Todas las dependencias transitivas han sido removidas a sus relvars.
-- -----------------------------------------------------------------------------

CREATE TABLE normalization.incident (
    incident_id      SERIAL       PRIMARY KEY,
    case_number      VARCHAR(20)  NOT NULL UNIQUE,
    date_occurrence  TIMESTAMP,
    block            VARCHAR(200),
    arrest           BOOLEAN,
    domestic         BOOLEAN,
    x_coordinate     INTEGER,
    y_coordinate     INTEGER,
    latitude         NUMERIC(12, 9),
    longitude        NUMERIC(12, 9),
    beat_id          INTEGER  REFERENCES normalization.beat(beat_id),
    ward_id          SMALLINT REFERENCES normalization.ward(ward_id),
    iucr_id          INTEGER  REFERENCES normalization.iucr(iucr_id),
    location_type_id INTEGER  REFERENCES normalization.location_type(location_type_id)
);

INSERT INTO normalization.incident (
    case_number, date_occurrence, block,
    arrest, domestic,
    x_coordinate, y_coordinate, latitude, longitude,
    beat_id, ward_id, iucr_id, location_type_id
)
SELECT
    c.case_number,
    c.incident_timestamp,
    c.block,
    c.arrest,
    c.domestic,
    c.x_coordinate::INTEGER,
    c.y_coordinate::INTEGER,
    c.latitude,
    c.longitude,
    b.beat_id,
    CASE WHEN TRIM(c.ward::VARCHAR) <> '' THEN c.ward::SMALLINT ELSE NULL END,
    i.iucr_id,
    lt.location_type_id
FROM cleaning.chicago_crimes        c
LEFT JOIN normalization.beat          b  ON c.beat::VARCHAR        = b.beat
LEFT JOIN normalization.iucr          i  ON TRIM(c.iucr)           = i.iucr
LEFT JOIN normalization.location_type lt ON c.location_description = lt.location_description
WHERE c.case_number IS NOT NULL
  AND TRIM(c.case_number) <> '';


-- =============================================================================
-- Índices para Optimización de Consultas Analíticas
-- =============================================================================

CREATE INDEX idx_incident_beat     ON normalization.incident(beat_id);
CREATE INDEX idx_incident_ward     ON normalization.incident(ward_id);
CREATE INDEX idx_incident_iucr     ON normalization.incident(iucr_id);
CREATE INDEX idx_incident_loc_type ON normalization.incident(location_type_id);
CREATE INDEX idx_incident_date     ON normalization.incident(date_occurrence);
CREATE INDEX idx_incident_arrest   ON normalization.incident(arrest);


-- =============================================================================
-- Verificación de Integridad
-- =============================================================================

SELECT 'normalization.beat'          AS tabla, COUNT(*) AS registros FROM normalization.beat
UNION ALL
SELECT 'normalization.ward',              COUNT(*) FROM normalization.ward
UNION ALL
SELECT 'normalization.fbi_code',          COUNT(*) FROM normalization.fbi_code
UNION ALL
SELECT 'normalization.iucr',              COUNT(*) FROM normalization.iucr
UNION ALL
SELECT 'normalization.location_type',     COUNT(*) FROM normalization.location_type
UNION ALL
SELECT 'normalization.incident',          COUNT(*) FROM normalization.incident
ORDER BY tabla;

SELECT
    (SELECT COUNT(*) FROM cleaning.chicago_crimes
     WHERE case_number IS NOT NULL
       AND TRIM(case_number) <> '')         AS cleaning_count,
    (SELECT COUNT(*) FROM normalization.incident) AS normalized_count,
    (SELECT COUNT(*) FROM cleaning.chicago_crimes
     WHERE case_number IS NOT NULL
       AND TRIM(case_number) <> '') =
    (SELECT COUNT(*) FROM normalization.incident) AS counts_match;

SELECT COUNT(*) AS incidentes_sin_beat FROM normalization.incident WHERE beat_id IS NULL;
SELECT COUNT(*) AS incidentes_sin_iucr FROM normalization.incident WHERE iucr_id IS NULL;
SELECT COUNT(*) AS incidentes_sin_ward FROM normalization.incident WHERE ward_id IS NULL;
