/*
 =========================================
 THE PROBLEMS
 =========================================
 • The Business Dilemma: The CMO needed to determine the True ROI of each marketing channel to finalize next quarter's budget. To ensure accurate financial planning, I was tasked with providing a verified report showing cleared, legally compliant net revenue per channel rather than relying on gross revenue or raw patient counts.
 • My Analytical / Data Trap: Calculating accurate net revenue required mapping the patient journey across three separate tables: financial (billing), clinical (sessions), and demographic (patients). The primary technical challenge was avoiding duplicate revenue counts caused by historical patient records (SCD Type 2) while ensuring only successfully cleared claims were included in the final totals.
 */
--_________________________________________________________________________________________________________________________________________________________________________________________________________________________
WITH session_telemetry AS (
    SELECT
        session_id,
        COUNTIF(event_type = 'VIDEO_LIVE') AS video_live_count
    FROM
        `raw.clean_telemetry`
    GROUP BY
        session_id
)
SELECT
    cp.acquisition_channel,
    COUNT(DISTINCT cp.patient_id) AS total_patients,
    SUM(cb.billed_amount) AS total_gross_revenue,
    SUM(
        CASE
            WHEN st.video_live_count = 0
            OR st.session_id IS NULL THEN cb.billed_amount
            ELSE 0
        END
    ) AS total_refunded_revenue,
    ROUND(
        SUM(cb.billed_amount) - SUM(
            CASE
                WHEN st.video_live_count = 0
                OR st.session_id IS NULL THEN cb.billed_amount
                ELSE 0
            END
        ),
        1
    ) AS true_net_revenue
FROM
    `raw.clean_billing` AS cb
    LEFT JOIN `raw.clean_sessions` AS cs ON cb.session_id = cs.session_id
    LEFT JOIN `raw.clean_patients_scd` AS cp ON cs.patient_id = cp.patient_id
    LEFT JOIN session_telemetry AS st ON cb.session_id = st.session_id
WHERE
    cb.status = 'PAID'
    AND cp.is_current = 1
GROUP BY
    cp.acquisition_channel
ORDER BY
    true_net_revenue DESC;

--___________________________________________________________________________________________________________________________________________________________________________________________________________________________
/*
 =========================================
 AUDIT FINDINGS & BREAKDOWN
 =========================================
 • My Technical Execution: I built a multi-table join connecting clean_billing, clean_sessions, and clean_patients_scd. I applied explicit filters (is_current = 1 AND status = 'PAID') to ensure only active patient profiles and verified payments were calculated. I then subtracted the previously audited ghost revenue ($0) to finalize the True Net Revenue metric.
 • My Strategic Business Insight: The data revealed a clear split between acquisition volume and patient value. TikTok and Meta generated high patient volume (~3,400 each) but low average revenue (~$647 per patient). In contrast, the Email channel acquired fewer patients (~3,000) but generated significantly higher value ($3,462 per patient).
 • My Recommendation: I recommend the CMO reallocate the primary conversion budget toward Email and Search channels to maximize ROI, while restricting TikTok and Meta spend to top-of-funnel brand awareness campaigns.
 */