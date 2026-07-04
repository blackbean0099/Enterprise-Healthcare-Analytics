
with clean_campaigns as 
(   SELECT 
        UPPER(TRIM(campaign_id)) as campaign_id,
        UPPER(TRIM(platform)) as platform,
        UPPER(TRIM(target)) as target
FROM
    `raw.dim_campaigns`
)
SELECT * 
FROM 
clean_campaigns
