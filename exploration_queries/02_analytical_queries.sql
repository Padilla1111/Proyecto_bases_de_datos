-- =============================================================================
-- Consultas Analíticas sobre Datos Normalizados
-- Proyecto BD: Análisis de Criminalidad en Chicago (Último Año)
-- =============================================================================
-- Prerrequisito: haber ejecutado 03_data_normalization.sql
--
-- Ejecución desde la raíz del proyecto:
--   psql -U [tuUsuario] -d crimenes -f exploration_queries/02_analytical_queries.sql
-- =============================================================================

-- =============================================================================
-- CONFIGURACIÓN DE EXPORTACIÓN (No imprimir en consola, guardar en CSV)
-- =============================================================================
\pset format csv

-- =============================================================================
-- 1. Tendencia Mensual de Criminalidad
-- =============================================================================
-- ¿En qué mes del año ocurren más crímenes? ¿Varía la tasa de arresto?
-- Permite identificar si la efectividad policial varía estacionalmente,
-- independientemente del volumen total de delitos.

\o 'results_csv/01_tendencia_mensual.csv'
SELECT
    EXTRACT(MONTH FROM i.date_occurrence)::SMALLINT          AS month,
    TO_CHAR(i.date_occurrence, 'TMMonth')                    AS month_name,
    COUNT(*)                                                 AS total_incidents,
    SUM(i.arrest::INT)                                       AS total_arrests,
    ROUND(100.0 * SUM(i.arrest::INT) / COUNT(*), 2)          AS arrest_rate_pct,
    RANK() OVER (ORDER BY COUNT(*) DESC)                     AS rank_by_volume
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
-- categorías raras inflen artificialmente la tasa.

\o 'results_csv/02_tasa_arresto_por_tipo.csv'
SELECT
    ic.primary_description,
    COUNT(*)                                                 AS total_incidents,
    SUM(i.arrest::INT)                                       AS total_arrests,
    ROUND(100.0 * SUM(i.arrest::INT) / COUNT(*), 2)          AS arrest_rate_pct,
    RANK() OVER (ORDER BY
        ROUND(100.0 * SUM(i.arrest::INT) / COUNT(*), 2) DESC
    )                                                        AS rank_by_arrest_rate
FROM normalization.incident i
JOIN normalization.iucr ic ON i.iucr_id = ic.iucr_id
GROUP BY ic.primary_description
HAVING COUNT(*) > 100
ORDER BY arrest_rate_pct DESC;


-- =============================================================================
-- 3. Variación Mes a Mes por Ward
-- =============================================================================
-- ¿Cómo evolucionó el volumen de criminalidad por ward respecto al mes
-- anterior? LAG() permite comparar cada ward consigo mismo en el tiempo,
-- revelando tendencias locales de incremento o reducción.

\o 'results_csv/03_variacion_mes_ward.csv'
WITH monthly_ward AS (
    SELECT
        w.ward_id,
        DATE_TRUNC('month', i.date_occurrence)               AS month,
        COUNT(*)                                             AS total_incidents
    FROM normalization.incident i
    JOIN normalization.ward w ON i.ward_id = w.ward_id
    GROUP BY w.ward_id, DATE_TRUNC('month', i.date_occurrence)
)
SELECT
    ward_id,
    TO_CHAR(month, 'YYYY-MM')                                AS month,
    total_incidents,
    LAG(total_incidents) OVER (
        PARTITION BY ward_id ORDER BY month
    )                                                        AS prev_month_incidents,
    total_incidents - LAG(total_incidents) OVER (
        PARTITION BY ward_id ORDER BY month
    )                                                        AS month_over_month_delta
FROM monthly_ward
ORDER BY ward_id, month;


-- =============================================================================
-- 4. Distribución por Franja Horaria
-- =============================================================================
-- ¿En qué franja horaria se concentran más delitos y cómo varía la
-- tasa de arresto entre franjas?

\o 'results_csv/04_distribucion_franja_horaria.csv'
SELECT
    CASE
        WHEN EXTRACT(HOUR FROM i.date_occurrence) BETWEEN  0 AND  5 THEN 'Madrugada'
        WHEN EXTRACT(HOUR FROM i.date_occurrence) BETWEEN  6 AND 11 THEN 'Mañana'
        WHEN EXTRACT(HOUR FROM i.date_occurrence) BETWEEN 12 AND 17 THEN 'Tarde'
        ELSE 'Noche'
    END                                                      AS time_period,
    COUNT(*)                                                 AS total_incidents,
    ROUND(100.0 * SUM(i.arrest::INT) / COUNT(*), 2)          AS arrest_rate_pct,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)       AS pct_of_total
FROM normalization.incident i
GROUP BY time_period
ORDER BY total_incidents DESC;

-- =============================================================================
-- 5. Top 3 Beats por Distrito
-- =============================================================================
-- ¿Cuáles son las 3 zonas de patrullaje (beat) con mayor cantidad de crímenes
-- dentro de cada distrito policial?

\o 'results_csv/05_top3_beats_distrito.csv'
WITH beats_clasificados AS (
    SELECT
        SUBSTRING(LPAD(beat::TEXT, 4, '0'), 1, 2)::INTEGER AS distrito,
        beat,
        COUNT(*)                                            AS conteo
    FROM raw.chicago_crimes
    GROUP BY distrito, beat
),
ranking AS (
    SELECT
        distrito,
        beat,
        conteo,
        ROW_NUMBER() OVER (PARTITION BY distrito ORDER BY conteo DESC) AS rank
    FROM beats_clasificados
)
SELECT distrito, beat, conteo
FROM ranking
WHERE rank <= 3
ORDER BY distrito, rank;


-- =============================================================================
-- 6. Evolución Mensual de Criminalidad
-- =============================================================================
-- ¿Cómo evoluciona la criminalidad mes a mes? ¿Cuál fue el aumento o
-- disminución exacta de incidentes respecto al mes anterior?

\o 'results_csv/06_evolucion_mensual.csv'
WITH mensual AS (
    SELECT
        TO_CHAR(
            TO_TIMESTAMP(date_occurrence, 'MM/DD/YYYY HH12:MI:SS AM'),
            'YYYY-MM'
        )        AS mes,
        COUNT(*) AS conteo
    FROM raw.chicago_crimes
    GROUP BY mes
)
SELECT
    mes,
    conteo,
    conteo - LAG(conteo) OVER (ORDER BY mes)              AS diferencia,
    ROUND(
        (conteo - LAG(conteo) OVER (ORDER BY mes))::NUMERIC
        / LAG(conteo) OVER (ORDER BY mes) * 100,
    2)                                                     AS cambio_porcentual
FROM mensual
ORDER BY mes;


-- =============================================================================
-- 7. Porcentaje de Crímenes por Tipo de Ubicación
-- =============================================================================
-- ¿Qué porcentaje del total histórico de crímenes aporta cada tipo de
-- ubicación al problema de inseguridad en la ciudad?

\o 'results_csv/07_porcentaje_crimenes_ubicacion.csv'
WITH total AS (
    SELECT COUNT(*) AS total_crimenes
    FROM raw.chicago_crimes
    WHERE location_description IS NOT NULL
      AND location_description != ''
)
SELECT
    location_description,
    COUNT(*)                                                   AS conteo,
    ROUND(COUNT(*) * 100.0 / (SELECT total_crimenes FROM total), 2) AS porcentaje
FROM raw.chicago_crimes
WHERE location_description IS NOT NULL
  AND location_description != ''
GROUP BY location_description
ORDER BY conteo DESC;


-- =============================================================================
-- 8. Patrón de Criminalidad por Día de la Semana
-- =============================================================================
-- ¿Qué días de la semana concentran más delitos y cómo varía la tasa
-- de arrestos? (1 = Lunes, 7 = Domingo)

\o 'results_csv/08_criminalidad_dia_semana.csv'
SELECT
    EXTRACT(ISODOW FROM i.date_occurrence)::SMALLINT         AS day_of_week_num,
    TRIM(TO_CHAR(i.date_occurrence, 'Day'))                  AS day_name,
    COUNT(*)                                                 AS total_incidents,
    SUM(i.arrest::INT)                                       AS total_arrests,
    ROUND(100.0 * SUM(i.arrest::INT) / COUNT(*), 2)          AS arrest_rate_pct
FROM normalization.incident i
WHERE i.date_occurrence IS NOT NULL
GROUP BY
    EXTRACT(ISODOW FROM i.date_occurrence),
    TRIM(TO_CHAR(i.date_occurrence, 'Day'))
ORDER BY day_of_week_num;


-- =============================================================================
-- 9. Impacto y Resolución de Crímenes Domésticos vs. No Domésticos
-- =============================================================================
-- ¿Qué proporción de los crímenes totales son de violencia doméstica y 
-- cómo se compara su tasa de arresto frente a los incidentes en vía pública/general?

\o 'results_csv/09_comparativa_domesticos.csv'
SELECT
    CASE WHEN i.domestic = TRUE THEN 'Doméstico' ELSE 'No Doméstico' END AS incident_type,
    COUNT(*)                                                 AS total_incidents,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)       AS pct_of_total_crimes,
    SUM(i.arrest::INT)                                       AS total_arrests,
    ROUND(100.0 * SUM(i.arrest::INT) / COUNT(*), 2)          AS arrest_rate_pct
FROM normalization.incident i
WHERE i.domestic IS NOT NULL
GROUP BY i.domestic
ORDER BY total_incidents DESC;


-- =============================================================================
-- 10. Top 20 Zonas Calientes (Hotspots) por Cuadra (Block)
-- =============================================================================
-- ¿Cuáles son las cuadras específicas que concentran la mayor cantidad
-- de incidentes en la ciudad? Se enfoca en reincidencia pura.

\o 'results_csv/10_top20_hotspots_bloques.csv'
SELECT
    i.block,
    COUNT(*)                                                 AS total_incidents,
    SUM(i.arrest::INT)                                       AS total_arrests,
    ROUND(100.0 * SUM(i.arrest::INT) / COUNT(*), 2)          AS arrest_rate_pct
FROM normalization.incident i
WHERE i.block IS NOT NULL
GROUP BY i.block
HAVING COUNT(*) > 20 -- Umbral mínimo para considerarlo un "hotspot" recurrente
ORDER BY total_incidents DESC
LIMIT 20;

-- =============================================================================
-- Restaurar la salida a la consola 
-- =============================================================================
\o
\pset format aligned