--GCP utenom GKE og isoc checkpoints
SELECT NULL AS cluster
      , project_name
      , NULL as namespace --TODO: Tror vi kan finne namespace et sted
      , env
      , team
      , tenant
      , app
      , cost_category
      , dato
      , service_description
      , sku_id
      , sku_description
      , calculated_cost
      , 'gcp-ressurser' as source
      , 'Google Cloud' as vendor 
from `nais-io.nais_billing_regional.cost_breakdown_excluding_nais`
where dato >= '2023-03-07'

UNION ALL

--GKE
SELECT cluster
      , project_name
      , namespace
      , env
      , team
      , tenant
      , app
      , cost_category
      , dato
      , service_description
      , sku_id
      , sku_description
      , calculated_cost
      , 'gke (nais)' as source
      , 'Google Cloud' as vendor 
from `nais-io.nais_billing_regional.cost_breakdown_nais`
where dato >= '2023-03-07'

UNION ALL 

-- ISOC checkpoints (skal fases ut)
select NULL as cluster
      , project_name
      , NULL as namespace
      , NULL as env
      , team
      , tenant
      , app
      , cost_category
      , dato
      , service_description
      , sku_id
      , sku_description
      , calculated_cost
      , 'gcp-ressurser' as source
      , 'Google Cloud' as vendor
from `nais-analyse-prod-2dcc.navbilling.cost_breakdown_checkpoints`
where dato >= '2023-03-07'

UNION ALL

-- Legacy billingdata fram til '2023-03-07'
select * from `nais-io.legacy_billing.cost_breakdown_total_gcp_static`

UNION ALL

--Aiven
SELECT NULL as cluster
     , project_name
     , NULL as namespace
     , env
     , team
     , tenant
     , NULL as app
     , cost_category
     , dato
     , service_description
     , sku_id
     , NULL as sku_description
     , calculated_cost
     , 'aiven' as source
     , 'Aiven' as vendor
FROM `nais-io.nais_billing_regional.cost_breakdown_aiven`