-- =============================================================================
-- Actividad D: Normalización a Cuarta Forma Normal (4FN)
-- Proyecto BD: Análisis de Criminalidad en Chicago (Último Año)
-- =============================================================================
-- Este script transforma el schema `raw` en un diseño relacional normalizado
-- hasta 4FN. La metodología sigue un **refresh destructivo** mediante el
-- schema `normalization`, garantizando idempotencia: cada ejecución genera
-- desde cero el schema y todas sus tablas, asegurando un estado consistente.
--
-- Prerrequisito: haber ejecutado 01_raw_data_schema_creation_and_load.sql
--
-- Ejecución desde la raíz del proyecto:
--   psql -U [tuUsuario] -d crimenes -f pipeline_scripts/03_data_normalization.sql
--
-- Los archivos de referencia (.csv) deben estar en la carpeta
-- `normalizacion_proyecto_final/` y sus rutas deben ajustarse según el
-- sistema operativo del usuario.
-- =============================================================================


-- =============================================================================
-- Análisis de Dependencias Funcionales y Multivaluadas
-- =============================================================================
--
-- La relación original (raw.chicago_crimes) contiene la siguiente clave:
--
--   Clave primaria candidata: { case_number }
--
-- A partir del Análisis Exploratorio (Actividad B), se identificaron las
-- siguientes dependencias funcionales no triviales:
--
--   (1) case_number → date_occurrence, block, arrest, domestic,
--                     x_coordinate, y_coordinate, latitude, longitude,
--                     beat, ward, iucr, fbi_cd, location_description
--
--   (2) iucr → primary_description, secondary_description, index_code, active
--       Los 332 códigos IUCR tienen descripciones predefinidas, confirmado
--       por la baja cardinalidad de primary_description (31 valores) y
--       secondary_description (310 valores) frente a los 232,588 registros.
--
--   (3) iucr → fbi_cd
--       Dependencia transitiva: el código IUCR determina unívocamente el
--       código FBI asociado, según el catálogo oficial de Chicago.
--       Al combinarse con (1), produce la cadena transitiva:
--       case_number → iucr → fbi_cd → {description, index_status, crime_type}
--       Esta cadena viola BCNF y debe descomponerse.
--
--   (4) fbi_cd → description, index_status, crime_type
--       Los 26 códigos FBI (01A, 01B, 02, ..., 26) tienen clasificaciones
--       fijas según el estándar UCR del FBI.
--
--   (5) beat → district_id
--       Los 274 beats se agrupan en distritos policiales. Cada beat pertenece
--       a exactamente un distrito.
--
--   (6) district_id → district_name
--       Los 22 distritos de la policía de Chicago tienen nombres oficiales.
--
--   (7) ward_id → neighborhoods
--       Los 50 distritos político-administrativos de Chicago tienen
--       colonias asociadas según el catálogo oficial de la ciudad.
--
-- Dependencias Multivaluadas no triviales:
--   No se identificaron MVDs independientes en el diseño: cada incidente
--   registra exactamente un valor de iucr, un beat, un ward y un tipo de
--   ubicación — no existen hechos multivaluados independientes entre sí.
--   Por lo tanto, alcanzar 4FN en este dataset equivale a eliminar todas
--   las dependencias transitivas y aislar cada tipo de hecho en su propia
--   relvar, garantizando que cada tabla registre un único tipo de hecho
--   sobre su clave.
--
-- Relvars resultantes y sus claves:
--   normalization.district        PK: { district_id }
--   normalization.beat            PK: { beat_id },  AK: { beat }
--   normalization.ward            PK: { ward_id }
--   normalization.fbi_code        PK: { fbi_cd }
--   normalization.iucr            PK: { iucr_id },  AK: { iucr }
--   normalization.location_type   PK: { location_type_id }, AK: { location_description }
--   normalization.incident        PK: { incident_id }, AK: { case_number }
-- =============================================================================


-- =============================================================================
-- 0. Preparación del schema
-- =============================================================================

DROP SCHEMA IF EXISTS normalization CASCADE;
CREATE SCHEMA normalization;


-- =============================================================================
-- Tablas de Referencia (Lookup Tables)
-- Cada relvar registra un único tipo de hecho sobre su clave → cumple 4FN.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. normalization.district
--
-- Registra el único hecho que depende del identificador de distrito:
--   district_id → district_name
--
-- Fuente: chicago_districts_names.csv (22 distritos policiales de Chicago)
-- -----------------------------------------------------------------------------

CREATE TABLE normalization.district (
    district_id   SMALLINT     PRIMARY KEY,
    district_name VARCHAR(100) NOT NULL
);

\COPY normalization.district (district_id, district_name)
FROM 'normalizacion_proyecto_final/chicago_districts_names (1).csv'
WITH (FORMAT CSV, HEADER true, DELIMITER ',', ENCODING 'UTF8');


-- -----------------------------------------------------------------------------
-- 2. normalization.beat
--
-- Registra el único hecho que depende del beat:
--   beat → district_id
--
-- La columna beat se define como UNIQUE para reflejar que es clave alterna.
-- Se separa de `district` para eliminar la dependencia transitiva:
--   case_number → beat → district_id → district_name
--
-- Fuente: chicago_beats.csv (277 beats activos de Chicago)
-- -----------------------------------------------------------------------------

CREATE TABLE normalization.beat (
    beat_id     SERIAL      PRIMARY KEY,
    beat        VARCHAR(10) NOT NULL UNIQUE,
    district_id SMALLINT    NOT NULL REFERENCES normalization.district(district_id)
);

\COPY normalization.beat (district_id, beat)
FROM 'normalizacion_proyecto_final/chicago_beats.csv'
WITH (FORMAT CSV, HEADER true, DELIMITER ',', ENCODING 'UTF8');


-- -----------------------------------------------------------------------------
-- 3. normalization.ward
--
-- Registra el único hecho que depende del identificador de ward:
--   ward_id → neighborhoods
--
-- Fuente: chicago_wards.csv (50 distritos político-administrativos de Chicago)
-- -----------------------------------------------------------------------------

CREATE TABLE normalization.ward (
    ward_id       SMALLINT PRIMARY KEY,
    neighborhoods TEXT
);

\COPY normalization.ward (ward_id, neighborhoods)
FROM 'normalizacion_proyecto_final/chicago_wards (1).csv'
WITH (FORMAT CSV, HEADER true, DELIMITER ',', ENCODING 'UTF8');


-- -----------------------------------------------------------------------------
-- 4. normalization.fbi_code
--
-- Registra los hechos que dependen del código FBI:
--   fbi_cd → description, index_status, crime_type
--
-- Al aislar esta relvar se rompe la dependencia transitiva identificada en (4),
-- evitando que las 26 descripciones del FBI se repitan en cada uno de los
-- ~200,000 registros del incidente.
--
-- Fuente: fbi_codes.csv (27 clasificaciones UCR del FBI)
-- -----------------------------------------------------------------------------

CREATE TABLE normalization.fbi_code (
    fbi_cd       VARCHAR(10)  PRIMARY KEY,
    description  VARCHAR(200),
    index_status VARCHAR(50),
    crime_type   VARCHAR(50)
);

\COPY normalization.fbi_code (fbi_cd, description, index_status, crime_type)
FROM 'normalizacion_proyecto_final/fbi_codes (1).csv'
WITH (FORMAT CSV, HEADER true, DELIMITER ',', ENCODING 'UTF8');


-- -----------------------------------------------------------------------------
-- 5. normalization.iucr
--
-- Registra los hechos que dependen del código IUCR:
--   iucr → primary_description, secondary_description, index_code, active, fbi_cd
--
-- La inclusión de fbi_cd como FK en esta tabla — en lugar de en `incident` —
-- refleja la dependencia funcional iucr → fbi_cd, eliminando la cadena
-- transitiva case_number → iucr → fbi_cd de la tabla principal.
--
-- El mapeo IUCR → FBI_CD se deriva directamente de los datos crudos (Opción B),
-- ya que cada registro del dataset ya contiene ambos códigos en conjunto.
-- Esto es equivalente al catálogo oficial iucr_fbi_cd que se proveyó de
-- referencia y evita una dependencia externa de formato xlsx.
--
-- Fuente: chicago_iucr.csv (410 códigos IUCR activos de Chicago) +
--         mapeo derivado de raw.chicago_crimes
-- -----------------------------------------------------------------------------

CREATE TABLE normalization.iucr (
    iucr_id               SERIAL       PRIMARY KEY,
    iucr                  VARCHAR(10)  NOT NULL UNIQUE,
    primary_description   VARCHAR(200) NOT NULL,
    secondary_description VARCHAR(200),
    index_code            VARCHAR(5),
    active                BOOLEAN,
    fbi_cd                VARCHAR(10)  REFERENCES normalization.fbi_code(fbi_cd)
);

-- Tabla temporal para carga bruta del catálogo de códigos IUCR
CREATE TEMP TABLE tmp_iucr (
    iucr                  VARCHAR(10),
    primary_description   VARCHAR(200),
    secondary_description VARCHAR(200),
    index_code            VARCHAR(5),
    active                TEXT
);

\COPY tmp_iucr (iucr, primary_description, secondary_description, index_code, active)
FROM 'normalizacion_proyecto_final/chicago_iucr.csv'
WITH (FORMAT CSV, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- Tabla temporal para el mapeo IUCR → FBI_CD derivado de los datos crudos
CREATE TEMP TABLE tmp_iucr_fbi (
    iucr   VARCHAR(10),
    fbi_cd VARCHAR(10)
);

INSERT INTO tmp_iucr_fbi (iucr, fbi_cd)
SELECT DISTINCT TRIM(iucr), TRIM(fbi_cd)
FROM raw.chicago_crimes
WHERE iucr IS NOT NULL AND fbi_cd IS NOT NULL
  AND TRIM(iucr) <> ''  AND TRIM(fbi_cd) <> '';

-- Inserción final uniendo el catálogo con el mapeo
INSERT INTO normalization.iucr (iucr, primary_description, secondary_description, index_code, active, fbi_cd)
SELECT
    TRIM(t.iucr),
    TRIM(t.primary_description),
    TRIM(t.secondary_description),
    TRIM(t.index_code),
    CASE WHEN LOWER(TRIM(t.active)) = 'true' THEN TRUE ELSE FALSE END,
    m.fbi_cd
FROM tmp_iucr t
LEFT JOIN tmp_iucr_fbi m ON TRIM(t.iucr) = m.iucr;


-- -----------------------------------------------------------------------------
-- 6. normalization.location_type
--
-- Registra el único hecho que depende del tipo de ubicación:
--   location_type_id → location_description
--
-- Los 131 tipos de lugar identificados en el EDA (STREET, APARTMENT,
-- RESIDENCE, etc.) son valores predefinidos del sistema de registro policial.
-- Aislarlos en una tabla propia elimina su repetición en los ~200,000
-- registros del incidente.
--
-- Los valores se extraen directamente de los datos crudos para garantizar
-- consistencia con lo que realmente existe en el dataset.
-- -----------------------------------------------------------------------------

CREATE TABLE normalization.location_type (
    location_type_id     SERIAL       PRIMARY KEY,
    location_description VARCHAR(200) NOT NULL UNIQUE
);

INSERT INTO normalization.location_type (location_description)
SELECT DISTINCT TRIM(location_description)
FROM raw.chicago_crimes
WHERE location_description IS NOT NULL AND TRIM(location_description) <> ''
ORDER BY 1;


-- =============================================================================
-- Tabla Principal de Hechos
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 7. normalization.incident
--
-- Registra únicamente los hechos que dependen directamente del caso:
--   case_number → date_occurrence, block, arrest, domestic,
--                 x_coordinate, y_coordinate, latitude, longitude,
--                 beat_id, ward_id, iucr_id, location_type_id
--
-- Todas las dependencias transitivas identificadas en el análisis fueron
-- removidas hacia sus relvars correspondientes. Al no quedar MVDs
-- independientes, esta relvar cumple con la Cuarta Forma Normal.
--
-- Decisiones técnicas:
-- * case_number se define como UNIQUE para reflejar que es clave alterna,
--   consistente con el hallazgo del EDA donde se identificaron 18 duplicados
--   que serán resueltos por la Actividad C (limpieza).
-- * Se utilizan llaves surrogadas (SERIAL) como PK, tal como se anunció en
--   la nota del README sobre el identificador del dataset original.
-- * Las conversiones de tipo siguen la misma lógica que la Actividad C:
--   TIMESTAMP para fechas, BOOLEAN para arrest/domestic, NUMERIC para
--   coordenadas geográficas.
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
    beat_id          INTEGER      REFERENCES normalization.beat(beat_id),
    ward_id          SMALLINT     REFERENCES normalization.ward(ward_id),
    iucr_id          INTEGER      REFERENCES normalization.iucr(iucr_id),
    location_type_id INTEGER      REFERENCES normalization.location_type(location_type_id)
);

-- Población de la tabla de incidentes desde los datos crudos
INSERT INTO normalization.incident (
    case_number,
    date_occurrence,
    block,
    arrest,
    domestic,
    x_coordinate,
    y_coordinate,
    latitude,
    longitude,
    beat_id,
    ward_id,
    iucr_id,
    location_type_id
)
SELECT
    TRIM(r.case_number),

    -- Conversión de fecha/hora: formato original MM/DD/YYYY HH:MI:SS AM/PM
    TO_TIMESTAMP(TRIM(r.date_occurrence), 'MM/DD/YYYY HH12:MI:SS AM'),

    TRIM(r.block),

    -- Conversión de booleanos: Y → TRUE, N → FALSE (consistente con Actividad C)
    CASE WHEN UPPER(TRIM(r.arrest))   = 'Y' THEN TRUE ELSE FALSE END,
    CASE WHEN UPPER(TRIM(r.domestic)) = 'Y' THEN TRUE ELSE FALSE END,

    -- Strings vacíos → NULL antes del cast (hallazgo del EDA: 113 registros sin coordenadas)
    NULLIF(TRIM(r.x_coordinate), '')::INTEGER,
    NULLIF(TRIM(r.y_coordinate), '')::INTEGER,
    NULLIF(TRIM(r.latitude),     '')::NUMERIC(12, 9),
    NULLIF(TRIM(r.longitude),    '')::NUMERIC(12, 9),

    -- Resolución de claves foráneas vía JOIN con las tablas de referencia
    b.beat_id,
    NULLIF(TRIM(r.ward), '')::SMALLINT,
    i.iucr_id,
    lt.location_type_id

FROM raw.chicago_crimes r
LEFT JOIN normalization.beat          b  ON TRIM(r.beat)                 = b.beat
LEFT JOIN normalization.iucr          i  ON TRIM(r.iucr)                 = i.iucr
LEFT JOIN normalization.location_type lt ON TRIM(r.location_description) = lt.location_description

WHERE TRIM(r.case_number) IS NOT NULL AND TRIM(r.case_number) <> '';


-- =============================================================================
-- Índices para Optimización de Consultas Analíticas
-- =============================================================================
-- Los índices se crean después de la carga masiva para evitar el costo de
-- reindexación incremental durante el INSERT.

CREATE INDEX idx_incident_beat     ON normalization.incident(beat_id);
CREATE INDEX idx_incident_ward     ON normalization.incident(ward_id);
CREATE INDEX idx_incident_iucr     ON normalization.incident(iucr_id);
CREATE INDEX idx_incident_loc_type ON normalization.incident(location_type_id);
CREATE INDEX idx_incident_date     ON normalization.incident(date_occurrence);
CREATE INDEX idx_incident_arrest   ON normalization.incident(arrest);


-- =============================================================================
-- Verificación de Integridad
-- =============================================================================

-- Conteo por tabla para confirmar que la carga fue completa
SELECT 'normalization.district'    AS tabla, COUNT(*) AS registros FROM normalization.district
UNION ALL
SELECT 'normalization.beat',                 COUNT(*) FROM normalization.beat
UNION ALL
SELECT 'normalization.ward',                 COUNT(*) FROM normalization.ward
UNION ALL
SELECT 'normalization.fbi_code',             COUNT(*) FROM normalization.fbi_code
UNION ALL
SELECT 'normalization.iucr',                 COUNT(*) FROM normalization.iucr
UNION ALL
SELECT 'normalization.location_type',        COUNT(*) FROM normalization.location_type
UNION ALL
SELECT 'normalization.incident',             COUNT(*) FROM normalization.incident
ORDER BY tabla;

-- Verificar que el número de incidentes coincide con los registros crudos válidos
SELECT
    (SELECT COUNT(*) FROM raw.chicago_crimes
     WHERE TRIM(case_number) IS NOT NULL AND TRIM(case_number) <> '') AS raw_count,
    (SELECT COUNT(*) FROM normalization.incident)                      AS normalized_count,
    (SELECT COUNT(*) FROM raw.chicago_crimes
     WHERE TRIM(case_number) IS NOT NULL AND TRIM(case_number) <> '') =
    (SELECT COUNT(*) FROM normalization.incident)                      AS counts_match;

-- Verificar incidentes sin beat asignado (beat en datos crudos sin correspondencia en catálogo)
SELECT COUNT(*) AS incidentes_sin_beat
FROM normalization.incident
WHERE beat_id IS NULL;
