(
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

    FROM `nais-io.legacy_billing.cost_breakdown_nais`

    UNION ALL

    SELECT NULL AS cluster
         , project_name
         , NULL AS namespace
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

    FROM `nais-io.legacy_billing.cost_breakdown_excluding_nais`
)