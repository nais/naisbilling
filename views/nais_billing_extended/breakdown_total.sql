--GCP utenom GKE og isoc checkpoints
SELECT NULL AS cluster
      , project_name
      , NULL as namespace
      , env
      , team
      , tenant
      , app
      , cost_category
      , dato
      , service_description
      , sku_id
      , sku_description
      , usage_amount
      , usage_unit
      , usage_amount_in_pricing_units
      , usage_pricing_unit
      , price_effective_price
      , cost
      , cost_at_list
      , calculated_cost
      , credits_amount
      , credits_type
      , 'gcp-ressurser' as source
from `nais-io.nais_billing_extended.breakdown_excluding_gke`
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
      , usage_amount
      , usage_unit
      , usage_amount_in_pricing_units
      , usage_pricing_unit
      , price_effective_price
      , cost
      , cost_at_list
      , calculated_cost
      , credits_amount
      , credits_type
      , 'gke (nais)' as source
from `nais-io.nais_billing_extended.breakdown_gke`
where dato >= '2023-03-07'

UNION ALL 

-- ISOC checkpoints (siste innslag 05.03.2024)
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
      , NULL as usage_amount
      , NULL as usage_unit
      , NULL as usage_amount_in_pricing_units
      , NULL as usage_pricing_unit
      , NULL as price_effective_price
      , calculated_cost as cost
      , NULL as cost_at_list
      , calculated_cost
      , NULL as credits_amount
      , NULL as credits_type
      , 'gcp-ressurser (marketplace)' as source
from `nais-analyse-prod-2dcc.navbilling.cost_breakdown_checkpoints`
where dato >= '2023-03-07'
