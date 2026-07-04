
WITH parsed_session AS (

SELECT 
    session_id,
    patient_id,
  COALESCE(
    SAFE.PARSE_DATETIME('%m/%d/%Y %H:%M:%S', start_time), 
    SAFE.PARSE_DATETIME('%Y-%m-%d %H:%M:%S', start_time) ,
    datetime '1900-01-01 00:00:00'
  ) AS start_time

FROM
    `raw.fact_sessions`
LIMIT 10
),
deduplicated_session AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
               PARTITION BY session_id
               ORDER BY session_id ASC
           ) AS row_session
    FROM
        parsed_session
)
SELECT
session_id,
	patient_id,
    	start_time
FROM deduplicated_session
WHERE row_session = 1