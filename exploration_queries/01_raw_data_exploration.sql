-- Total de registros
SELECT COUNT(*) as registros_totales,
       COUNT(case_number) as non_null_case_numbers,
       COUNT(primary_description) as non_null_primary_desc,
       COUNT(latitude) as non_null_latitude,
       COUNT(longitude) as non_null_longitude
FROM raw.chicago_crimes;

-- Comprobamos si case_number es valor único
with aux as (
SELECT COUNT(*) as registros_totales,
		count( DISTINCT chicago_crimes.case_number ) as case_numbers
from raw.chicago_crimes
)
SELECT registros_totales = case_numbers as case_nums_son_valores_unicos
from aux;

