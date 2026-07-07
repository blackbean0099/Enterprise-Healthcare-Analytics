/*
 =========================================
 THE PROBLEMS
 =========================================
 • Mixed Time Formats: The session start times were recorded in completely different layouts (some used slashes like MM/DD/YYYY, others used dashes like YYYY-MM-DD), which confuses the database.
 • Duplicate Sessions: System glitches likely caused the exact same telehealth session to be logged multiple times in the raw data.
 */
--____________________________________________________________________________________________________________

CREATE OR REPLACE VIEW `raw.clean_sessions` AS

WITH parsed_session AS (
    SELECT
        session_id,
        patient_id,
        COALESCE(
            SAFE.PARSE_DATETIME('%m/%d/%Y %H:%M:%S', start_time),
            SAFE.PARSE_DATETIME('%Y-%m-%d %H:%M:%S', start_time),
            DATETIME '1900-01-01 00:00:00'
        ) AS start_time
    FROM
        `enterprise-health-analytics.raw.fact_sessions`
),
deduplicated_session AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY session_id
            ORDER BY
                start_time desc
        ) AS row_session
    FROM
        parsed_session
)
SELECT
    session_id,
    patient_id,
    start_time
FROM
    deduplicated_session
WHERE
    row_session = 1;
     
--_________________________________________________________________________________________
/*
=========================================
 AUDIT FINDINGS & BREAKDOWN
 =========================================
 • Time Formats Fixed: Translated all the mixed start times into one clean, standard format so we can calculate exact minutes and seconds later. 
 • Safety Net Added: Used a backup date (1900-01-01) just in case a time was completely corrupted, preventing the whole table from crashing.
 • Clean Deduplication: Grouped everything by the unique session ID and safely removed any copied rows from the system.
 */