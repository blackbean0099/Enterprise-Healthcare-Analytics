/*
 =========================================
 THE PROBLEMS
 =========================================
 • Inconsistent Capitalization: The raw text had mixed casing (like 'TikTok' and 'tiktok'), which stops the database from grouping them together correctly.
 • Hidden Spaces: There were invisible spaces at the beginning and end of text words, which breaks table joins later on.
 */
--__________________________________________________________________________________________________________________________________________________

CREATE OR REPLACE VIEW `raw.clean_campaigns` AS 

SELECT
    UPPER(TRIM(campaign_id)) as campaign_id,
    UPPER(TRIM(platform)) as platform,
    UPPER(TRIM(target)) as target
FROM
    `raw.dim_campaigns`;
--_________________________________________________________________________________________________
    /*
     =========================================
     AUDIT FINDINGS & BREAKDOWN
     =========================================
     • Text Formatting Standardized: Used UPPER and TRIM functions to make all text fields look exactly the same across the table.
     • Ready for Analysis: The campaign data is now clean and safely prepared for accurate marketing tracking and table joins.
     */