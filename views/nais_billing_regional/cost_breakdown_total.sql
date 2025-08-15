--GCP utenom GKE og isoc checkpoints
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
      calculated_cost,
      'gcp-ressurser' AS source,
      'Google Cloud' AS vendor
FROM
      `nais-io.nais_billing_regional.cost_breakdown_excluding_nais`
WHERE
      dato >= '2023-03-07'

UNION ALL

--GKE
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
      calculated_cost,
      'gke (nais)' AS source,
      'Google Cloud' AS vendor
FROM
      `nais-io.nais_billing_regional.cost_breakdown_nais`
WHERE
      dato >= '2023-03-07'

UNION ALL

-- ISOC checkpoints (skal fases ut)
SELECT
      NULL AS cluster,
      project_name,
      NULL AS namespace,
      NULL AS env,
      team,
      tenant,
      app,
      cost_category,
      dato,
      service_description,
      sku_id,
      sku_description,
      NULL AS resource_name,
      calculated_cost,
      'gcp-ressurser' AS source,
      'Google Cloud' AS vendor
FROM
      `nais-analyse-prod-2dcc.navbilling.cost_breakdown_checkpoints`
WHERE
      dato >= '2023-03-07'

UNION ALL

-- Legacy billingdata fram til '2023-03-07'
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
      calculated_cost,
      source,
      vendor
FROM
      `nais-io.legacy_billing.cost_breakdown_total_gcp_static`