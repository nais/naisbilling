SELECT b.project_name 
        , b.project_id
        , b.env
        , IFNULL(b.team_label, b.team) as team
        , COALESCE(b.tenant, 'nav') as tenant
        , app_label as app
        , CASE
            WHEN starts_with(b.team, 'nais') THEN 'Plattform'
            WHEN b.team in ('nada', 'knada-gcp', 'knada-dev') THEN 'Dataplattform'
            WHEN b.team = 'isoc' THEN 'ISOC/SecOps'
            WHEN (b.project_name LIKE '%-dev' OR b.project_name LIKE '%-prod') THEN 'Produktteam'
            ELSE 'Annet'
        END AS cost_category
        , DATE(b.usage_start_time) AS dato
        , b.service_description
        , b.sku_id
        , b.sku_description
        , sum(usage_amount) as usage_amount
        , usage_unit
        , sum(usage_amount_in_pricing_units) as usage_amount_in_pricing_units
        , usage_pricing_unit
        , price_effective_price
        , SUM(b.cost) as cost
        , sum(cost_at_list) as cost_at_list
        , (SUM(CAST(b.cost * 1000000 AS int64)) + SUM(CAST(IFNULL(credits_amount, 0) * 1000000 AS int64))) / 1000000 AS calculated_cost
        , SUM(b.credits_amount) as credits_amount
        , credits_type
    
FROM `nais-io.nais_billing_extended.billing_export` b

WHERE b.k8s_namespace IS NULL -- Betyr at det ikke er en GKE-kostnad

GROUP BY project_name, project_id, env, tenant, team, dato, service_description, sku_id, sku_description, app, cost_category, usage_unit, usage_pricing_unit, price_effective_price, credits_type
