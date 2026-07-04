WITH parsed_billing AS (
SELECT
    claim_id,
   	session_id,
  	UPPER(TRIM(severity_level)) AS severity_level,
  	 CAST(TRIM(REPLACE(REPLACE(billed_amount, '$', ''), ',', '')) AS NUMERIC) AS billed_amount,
    UPPER(TRIM(status)) AS status
FROM 
    raw.fact_billing
    ),
deduplicated_billing AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
               PARTITION BY claim_id
               ORDER BY claim_id ASC
           ) AS row_billing
    FROM
        parsed_billing)
SELECT
        claim_id,
        session_id,
        	severity_level	,
            billed_amount	,
            status
FROM deduplicated_billing
WHERE row_billing = 1
