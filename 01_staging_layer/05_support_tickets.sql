/*
 =========================================
 THE PROBLEMS
 =========================================
 • Messy Text: Support categories likely have extra invisible spaces or mixed capital letters, which makes it impossible to accurately count ticket types.
 • Broken Dates: Ticket creation times could be corrupted or missing, which would break our ability to measure how fast tickets are submitted after an app crash.
 • Duplicate Tickets: A system bug might have saved the exact same support ticket more than once.
 */
--___________________________________________________________________________________________________________________________________

CREATE OR REPLACE VIEW `raw.clean_support_tickets` AS

WITH parsed_support_ticket AS (
    SELECT
        ticket_id,
        patient_id,
        session_id,
        UPPER(TRIM(category)) AS category,
        csat_score,
        COALESCE(
            SAFE.PARSE_DATETIME('%Y-%m-%d %H:%M:%S', created_at),
            DATETIME '1900-01-01 00:00:00'
        ) AS created_at
    FROM
        `enterprise-health-analytics.raw.fact_support_tickets`
),
deduplicated_support_ticket AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY ticket_id
            ORDER BY
                created_at desc
        ) AS row_support_ticket
    FROM
        parsed_support_ticket
)
SELECT
    ticket_id,
    patient_id,
    session_id,
    category,
    csat_score,
    created_at
FROM
    deduplicated_support_ticket
WHERE
    row_support_ticket = 1;
    
--__________________________________________________________________________________
/*
=========================================
 AUDIT FINDINGS & BREAKDOWN
 =========================================
 • Text Standardized: Used UPPER and TRIM so all support categories match perfectly across the board.
 • Time Formats Fixed: Converted creation times into a standard format and added a backup date (1900-01-01) to stop any broken dates from crashing the query.
 • Clean Deduplication: Grouped everything by the ticket ID and kept only the most recent one, wiping out any duplicate copies.
 */