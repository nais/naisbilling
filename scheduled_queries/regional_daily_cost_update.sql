BEGIN

DELETE FROM `nais-io.nais_billing_regional.cost_breakdown_total_daily_update`
WHERE dato >= DATE_SUB(CURRENT_DATE('Europe/Oslo'), INTERVAL 10 DAY)
  AND dato < CURRENT_DATE('Europe/Oslo');

INSERT INTO `nais-io.nais_billing_regional.cost_breakdown_total_daily_update`
SELECT
  CAST(NULL AS STRING) AS cluster,
  project_name,
  CAST(NULL AS STRING) AS namespace,
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
  CAST(NULL AS STRING) AS resource_name,
  SUM(calculated_cost) AS calculated_cost,
  'gke (nais)' AS source,
  'Google Cloud' AS vendor
FROM `nais-io.nais_billing_regional.cost_breakdown_nais`
WHERE dato >= DATE_SUB(CURRENT_DATE('Europe/Oslo'), INTERVAL 10 DAY)
  AND dato < CURRENT_DATE('Europe/Oslo')
  AND partition_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 13 DAY)
GROUP BY cluster, project_name, namespace, env, team, tenant, app,
         cost_category, dato, service_description, sku_id, sku_description,
         resource_name, source, vendor;

END