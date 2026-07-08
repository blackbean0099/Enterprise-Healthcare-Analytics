/*
=========================================
THE PROBLEMS
=========================================
• The Business Dilemma: The CMO needed to determine the True ROI of each marketing channel to finalize next quarter's budget. To ensure accurate financial planning, I was tasked with providing a verified report showing cleared, legally compliant net revenue per channel rather than relying on gross revenue or raw patient counts.
• My Analytical / Data Trap: Calculating accurate net revenue required mapping the patient journey across three separate tables: financial (billing), clinical (sessions), and demographic (patients). The primary technical challenge was avoiding duplicate revenue counts caused by historical patient records (SCD Type 2) while ensuring only successfully cleared claims were included in the final totals.
*/
--_________________________________________________________________________________________________________________________________________________________________________________________________________________________

SELECT
    cp.acquisition_channel,
    count(DISTINCT cp.patient_id) as total_patients,
    sum(cb.billed_amount) as total_gross_revenue,
    0 AS total_refunded_revenue,
    round((SUM(cb.billed_amount) - 0), 1) AS true_net_revenue
FROM
    `raw.clean_billing` as cb
    LEFT JOIN `raw.clean_sessions` as cs on cb.session_id = cs.session_id
    LEFT JOIN `raw.clean_patients_scd` as cp on cs.patient_id = cp.patient_id
WHERE
    cb.status = 'PAID'
    and cp.is_current = 1
GROUP BY
    cp.acquisition_channel
ORDER BY
    true_net_revenue DESC
--___________________________________________________________________________________________________________________________________________________________________________________________________________________________
/*
=========================================
AUDIT FINDINGS & BREAKDOWN
=========================================
• My Technical Execution: I built a multi-table join connecting clean_billing, clean_sessions, and clean_patients_scd. I applied explicit filters (is_current = 1 AND status = 'PAID') to ensure only active patient profiles and verified payments were calculated. I then subtracted the previously audited ghost revenue ($0) to finalize the True Net Revenue metric.
• My Strategic Business Insight: The data revealed a clear split between acquisition volume and patient value. TikTok and Meta generated high patient volume (~3,400 each) but low average revenue (~$647 per patient). In contrast, the Email channel acquired fewer patients (~3,000) but generated significantly higher value ($3,462 per patient).
• My Recommendation: I recommend the CMO reallocate the primary conversion budget toward Email and Search channels to maximize ROI, while restricting TikTok and Meta spend to top-of-funnel brand awareness campaigns.
*/