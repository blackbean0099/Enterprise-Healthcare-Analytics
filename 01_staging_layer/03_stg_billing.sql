/*
=========================================
THE PROBLEMS
=========================================
• Inconsistent Text: The severity levels and payment statuses likely contained hidden spaces and mixed capital letters (like ' paid ' vs 'PAID'), which causes grouping errors.
• Corrupted Money Values: The billed amount was saved as text with dollar signs ($) and commas (,), making it impossible for the database to add or calculate total revenue.
• Duplicate Claims: System glitches may have recorded the exact same billing claim multiple times. 
*/
--______________________________________________________________________________________________________________________________________________________________________________________
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

--___________________________________________________________________________________________
/*
=========================================
AUDIT FINDINGS & BREAKDOWN
=========================================
• Text Formatting Standardized: Used UPPER and TRIM to make sure all statuses and severity levels are perfectly clean and match each other.
• Financial Math Fixed: Stripped out all currency symbols and converted the billed amount into a pure number so we can safely calculate revenue later.
• Clean Deduplication: Used a window function to group rows by claim ID and pick just one, safely deleting any exact copies from the raw data.
*/