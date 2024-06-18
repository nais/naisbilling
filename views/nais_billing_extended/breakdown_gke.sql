SELECT b.project_name 
        , b.project_id
        , case
            when b.env is null then 
                case
                    when b.project_name like '%-dev' then 'dev'
                    when b.project_name like '%-prod' then 'prod'
                    when b.project_name like '%-ci' then 'ci'
                    else null
                end
            else env
        end as env
        , b.k8s_cluster as cluster
        , b.k8s_namespace as namespace
        , case --TODO: håndtere knada-teams
            when b.k8s_namespace in (select team from `nais_billing_regional.nais_teams`) and not starts_with(b.k8s_namespace, 'nais') then b.k8s_namespace
            when b.project_name in ('knada-gcp', 'knada-dev') then b.k8s_namespace
            else b.team 
        end as team
        , COALESCE(b.tenant, 'nav') as tenant
        , COALESCE(b.k8s_app, app_label) as app
        -- cost_category vil ikke fordele GKE-kostnader hvis vi bare baserer på b.team
        , CASE
            WHEN b.k8s_namespace in (select distinct team from `nais_billing_regional.nais_teams`) and not starts_with(b.k8s_namespace, 'nais') THEN 'Produktteam'
            WHEN starts_with(b.team, 'nais') THEN 'Plattform'
            WHEN b.team in ('nada', 'dataplattform') THEN 'Dataplattform'
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

WHERE b.k8s_namespace IS NOT NULL -- Betyr at det er en GKE-kostnad

GROUP BY project_name, project_id, env, tenant, team, dato, service_description, sku_id, sku_description, app, cost_category, namespace, cluster, usage_unit, usage_pricing_unit, price_effective_price, credits_type
