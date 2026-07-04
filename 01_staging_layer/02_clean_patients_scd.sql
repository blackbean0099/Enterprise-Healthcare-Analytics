WITH parsed_patients AS (
    SELECT
        patient_sk,
        patient_id,
        UPPER(TRIM(acquisition_channel)) AS acquisition_channel,
        birth_year,
        CAST(TRIM(REPLACE(REPLACE(lifetime_value, '$', ''), ',', '')) AS NUMERIC) AS lifetime_value,
        COALESCE(
            SAFE.PARSE_DATE('%Y-%m-%d', valid_from),
            SAFE.PARSE_DATE('%m/%d/%Y', valid_from),
            DATE '1900-01-01'
        ) AS valid_from,
        COALESCE(
            SAFE.PARSE_DATE('%Y-%m-%d', valid_to),
            SAFE.PARSE_DATE('%m/%d/%Y', valid_to),
            DATE '9999-12-31'
        ) AS valid_to,
        is_current
    FROM 
        `enterprise-health-analytics.raw.dim_patients_scd`
),

deduplicated_patients AS (
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY patient_id, valid_from 
            ORDER BY is_current DESC, patient_sk DESC
        ) AS row_num
    FROM 
        parsed_patients
)

SELECT 
    patient_sk,
    patient_id,
    acquisition_channel,
    birth_year,
    lifetime_value,
    valid_from,
    valid_to,
    is_current
FROM 
    deduplicated_patients
WHERE 
    row_num = 1;