-- =============================================================================
-- Consultas Analíticas sobre Datos Normalizados
-- Proyecto BD: Análisis de Criminalidad en Chicago (Último Año)
-- =============================================================================
-- Este script contiene las consultas de interés que responden las preguntas
-- analíticas centrales del proyecto, ejecutadas directamente sobre el schema
-- `normalization`.
--
-- Prerrequisito: haber ejecutado 03_data_normalization.sql
--
-- Ejecución desde la raíz del proyecto:
--   psql -U [tuUsuario] -d crimenes -f exploration_queries/02_analytical_queries.sql
-- =============================================================================


-- =============================================================================
-- 1. Tendencia Mensual de Criminalidad
-- =============================================================================

-- ¿En qué mes del año ocurren más crímenes? ¿Varía la tasa de arresto?
-- Permite identificar si la efectividad policial varía estacionalmente,
-- independientemente del volumen total de delitos.
SELECT
    EXTRACT(MONTH FROM i.date_occurrence)::SMALLINT          AS month,
    TO_CHAR(i.date_occurrence, 'TMMonth')                    AS month_name,
    COUNT(*)                                                 AS total_incidents,
    SUM(i.arrest::INT)                                       AS total_arrests,
    ROUND(100.0 * SUM(i.arrest::INT) / COUNT(*), 2)          AS arrest_rate_pct
FROM normalization.incident i
GROUP BY
    EXTRACT(MONTH FROM i.date_occurrence),
    TO_CHAR(i.date_occurrence, 'TMMonth')
ORDER BY month;


-- =============================================================================
-- 2. Tasa de Arresto por Tipo de Crimen
-- =============================================================================

-- ¿Qué tipos de crimen tienen la tasa de arresto más alta y más baja?
-- Se consideran solo tipos con más de 100 incidentes para evitar que
-- categorías raras inflen artificialmente la tasa (ej. un único delito
-- con arresto = 100%).
SELECT
    ic.primary_description,
    COUNT(*)                                                 AS total_incidents,
    SUM(i.arrest::INT)                                       AS total_arrests,
    ROUND(100.0 * SUM(i.arrest::INT) / COUNT(*), 2)          AS arrest_rate_pct
FROM normalization.incident i
JOIN normalization.iucr ic ON i.iucr_id = ic.iucr_id
GROUP BY ic.primary_description
HAVING COUNT(*) > 100
ORDER BY arrest_rate_pct DESC;


-- =============================================================================
-- 3. Concentración Geográfica por Distrito
-- =============================================================================

-- ¿Qué distritos concentran el mayor volumen de criminalidad?
-- pct_of_total cuantifica qué fracción del crimen total de la ciudad
-- corresponde a cada distrito, sin depender del tamaño absoluto.
SELECT
    d.district_name,
    COUNT(*)                                                 AS total_incidents,
    SUM(i.arrest::INT)                                       AS total_arrests,
    ROUND(100.0 * SUM(i.arrest::INT) / COUNT(*), 2)          AS arrest_rate_pct,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2
    )                                                        AS pct_of_total
FROM normalization.incident   i
JOIN normalization.beat        b ON i.beat_id      = b.beat_id
JOIN normalization.district    d ON b.district_id  = d.district_id
GROUP BY d.district_name
ORDER BY total_incidents DESC;


-- =============================================================================
-- 4. Distribución por Franja Horaria
-- =============================================================================

-- ¿En qué franja horaria se concentran más delitos?
-- Se categorizan los incidentes en Madrugada, Mañana, Tarde y Noche
-- para comunicar patrones temporales a audiencias no técnicas.
SELECT
    CASE
        WHEN EXTRACT(HOUR FROM i.date_occurrence) BETWEEN  0 AND  5 THEN 'Madrugada'
        WHEN EXTRACT(HOUR FROM i.date_occurrence) BETWEEN  6 AND 11 THEN 'Mañana'
        WHEN EXTRACT(HOUR FROM i.date_occurrence) BETWEEN 12 AND 17 THEN 'Tarde'
        ELSE 'Noche'
    END                                                      AS time_period,
    COUNT(*)                                                 AS total_incidents,
    ROUND(100.0 * SUM(i.arrest::INT) / COUNT(*), 2)          AS arrest_rate_pct
FROM normalization.incident i
GROUP BY time_period
ORDER BY total_incidents DESC;
