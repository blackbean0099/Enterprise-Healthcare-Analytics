/*
 =========================================
 THE PROBLEMS
 =========================================
 • Trapped Data: Important device details (like the operating system, RAM, and internet speed) were buried inside a single giant block of text, making it impossible to read or filter.
 • Unreadable Time: The event time was saved as a massive string of numbers (epoch time) instead of a normal calendar date and clock time.
 • Duplicate Events: A system bug might have logged the exact same app event more than once.
 */
 --__________________________________________________________________________________________________________________________________________________________________________

CREATE OR REPLACE VIEW `raw.clean_telemetry` AS

WITH parsed_telemetry AS (
    SELECT
        event_id,
        session_id,
        UPPER(TRIM(event_type)) AS event_type,
        DATETIME(TIMESTAMP_SECONDS (epoch_time)) AS epoch_time_readable,
        JSON_VALUE(payload, '$.hw.os') as operating_system,
        SAFE_cast(JSON_VALUE(payload, '$.hw.ram_gb') as INT64) as ram_gb,
        JSON_VALUE(payload, '$.net[0].ip') as ip_address,
        SAFE_cast(JSON_VALUE(payload, '$.net[0].ping') as INT64) as net_ping
    FROM
        `enterprise-health-analytics.raw.fact_telemetry`
),
deduplicated_telemetry as (
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY event_id,
            session_id
            ORDER BY
                epoch_time_readable DESC
        ) AS row_telemetry
    FROM
        parsed_telemetry
)
SELECT
    event_id,
    session_id,
    event_type,
    epoch_time_readable,
    operating_system,
    ram_gb,
    ip_address,
    net_ping
FROM
    deduplicated_telemetry
WHERE
    row_telemetry = 1;

--___________________________________________________________________________________________________
/*
=========================================
AUDIT FINDINGS & BREAKDOWN
=========================================
• Data Unlocked: Successfully dug into the text block and pulled out the OS, RAM, IP address, and ping speed into their own separate, clean columns.
• Time Fixed: Translated the giant number into a normal, readable date and time so we can track exactly when an app crash happens.
• Clean Deduplication: Grouped the data to remove any copied rows, ensuring our event tracking is 100% accurate.
*/