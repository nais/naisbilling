MERGE `nais-io.nais_billing_regional.nais_teams_history` AS target
USING (
  SELECT DISTINCT team, tenant 
  FROM `nais-io.nais_billing_regional.gcp_billing_export`
  WHERE (team IS NOT NULL OR tenant IS NOT NULL)
    AND partition_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)
) AS source
ON target.team IS NOT DISTINCT FROM source.team 
  AND target.tenant IS NOT DISTINCT FROM source.tenant
WHEN NOT MATCHED THEN
  INSERT (team, tenant)
  VALUES (source.team, source.tenant);