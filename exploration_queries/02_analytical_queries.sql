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
