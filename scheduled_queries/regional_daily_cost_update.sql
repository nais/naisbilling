MERGE `nais-io.nais_billing_regional.cost_breakdown_total_daily_update` AS target
USING (
  SELECT
    NULL AS cluster,
    project_name,
    NULL AS namespace,
    env,
    team,
    tenant,
    app,
    cost_category,
    dato,
    service_description,
    sku_id,
    sku_description,
    resource_name,
    SUM(calculated_cost) AS calculated_cost,
    'gcp-ressurser' AS source,
    'Google Cloud' AS vendor
  FROM `nais-io.nais_billing_regional.cost_breakdown_excluding_nais`
  WHERE dato >= DATE_SUB(CURRENT_DATE('Europe/Oslo'), INTERVAL 10 DAY)
    AND dato < CURRENT_DATE('Europe/Oslo')
    AND partition_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 13 DAY)
  GROUP BY cluster, project_name, namespace, env, team, tenant, app,
           cost_category, dato, service_description, sku_id, sku_description,
           resource_name, source, vendor

  UNION ALL

  SELECT
    cluster,
    project_name,
    namespace,
    env,
    team,
    tenant,
    app,
    cost_category,
    dato,
    service_description,
    sku_id,
    sku_description,
    NULL AS resource_name,
    SUM(calculated_cost) AS calculated_cost,
    'gke (nais)' AS source,
    'Google Cloud' AS vendor
  FROM `nais-io.nais_billing_regional.cost_breakdown_nais`
  WHERE dato >= DATE_SUB(CURRENT_DATE('Europe/Oslo'), INTERVAL 10 DAY)
    AND dato < CURRENT_DATE('Europe/Oslo')
    AND partition_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 13 DAY)
  GROUP BY cluster, project_name, namespace, env, team, tenant, app,
           cost_category, dato, service_description, sku_id, sku_description,
           resource_name, source, vendor
) AS source
ON  target.dato                  = source.dato
AND target.project_name          IS NOT DISTINCT FROM source.project_name
AND target.cluster               IS NOT DISTINCT FROM source.cluster
AND target.namespace             IS NOT DISTINCT FROM source.namespace
AND target.env                   IS NOT DISTINCT FROM source.env
AND target.team                  IS NOT DISTINCT FROM source.team
AND target.tenant                IS NOT DISTINCT FROM source.tenant
AND target.app                   IS NOT DISTINCT FROM source.app
AND target.cost_category         IS NOT DISTINCT FROM source.cost_category
AND target.service_description   IS NOT DISTINCT FROM source.service_description
AND target.sku_id                IS NOT DISTINCT FROM source.sku_id
AND target.sku_description       IS NOT DISTINCT FROM source.sku_description
AND target.resource_name         IS NOT DISTINCT FROM source.resource_name
AND target.source                IS NOT DISTINCT FROM source.source
AND target.vendor                IS NOT DISTINCT FROM source.vendor
WHEN MATCHED AND target.calculated_cost != source.calculated_cost THEN
  UPDATE SET calculated_cost = source.calculated_cost
WHEN NOT MATCHED BY TARGET THEN
  INSERT ROW
WHEN NOT MATCHED BY SOURCE
  AND target.dato >= DATE_SUB(CURRENT_DATE('Europe/Oslo'), INTERVAL 10 DAY)
  AND target.dato < CURRENT_DATE('Europe/Oslo')
THEN
  DELETE