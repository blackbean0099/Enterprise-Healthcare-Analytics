/*
=========================================
THE PROBLEMS
=========================================
• The Business Dilemma: The CMO and CFO are arguing over where to spend the next marketing budget. They have assumptions about TikTok vs. Email, but no hard numbers to prove ROI.
• The SCD Data Trap: Because patient history is tracked over time (SCD Type 2), counting rows blindly will double-count patients who had profile updates, completely destroying the Average LTV and CAC math.
• Missing Metrics: We had a birth year, but no current age column to prove the demographic hypothesis.
*/
--____________________________________________________________________________________________________________________________________________________

WITH analyze_patients AS (
    SELECT
        patient_sk,
        patient_id,
        acquisition_channel,
        EXTRACT(YEAR FROM CURRENT_DATE()) - birth_year AS age,
        birth_year,
        lifetime_value,
        valid_from,
        valid_to,
        is_current
    FROM
        `raw.clean_patients_scd`
)
SELECT
    acquisition_channel,
    count(distinct(patient_id)) as total_patients,
    ROUND(50000 / COUNT(DISTINCT patient_id), 1) as CAC,
    ROUND(avg(age), 1) as avg_age,
    ROUND(avg(lifetime_value), 1) as avg_lifetime_value
FROM
    analyze_patients
WHERE
    is_current = 1
GROUP BY
    acquisition_channel;

--_____________________________________________________________________________________________________________________________________
/*
=========================================
AUDIT FINDINGS & BREAKDOWN
=========================================
• Accurate Demographic Math: Dynamically calculated patient age using CURRENT_DATE() so the dashboard stays accurate every year.
• The SCD Filter: Safely isolated only active users (is_current = 1) and used COUNT(DISTINCT patient_id) to ensure exact CAC calculations without duplicate counting.
• Strategic Business Insight: The CMO's hypothesis is 100% correct. Customer Acquisition Cost (CAC) is identical across all channels (~$13.50). However, Email generates Boomers (Age 71) with a massive $1,898 Lifetime Value, while TikTok only yields Gen Z (Age 24) with a $100 LTV. 
• Recommendation: The CFO should heavily shift the budget away from TikTok and prioritize Email and Meta for maximum revenue.
*/