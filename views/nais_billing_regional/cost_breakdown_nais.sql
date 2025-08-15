SELECT project_name 
        , project_id
        , case
            when env is null then 
                case
                    when project_name like '%-dev' then 'dev'
                    when project_name like '%-prod' then 'prod'
                    when project_name like '%-ci' then 'ci'
                    else null
                end
            else env
        end as env
        , k8s_cluster as cluster
        , k8s_namespace as namespace
        , case
            when k8s_namespace in (select team from `nais_billing_regional.nais_teams`) and not starts_with(k8s_namespace, 'nais') then k8s_namespace
            when project_name in ('knada-gcp', 'knada-dev') then k8s_namespace
            else team 
        end as team
        , COALESCE(tenant, 'nav') as tenant
        , COALESCE(k8s_app, app_label) as app
        -- cost_category vil ikke fordele GKE-kostnader hvis vi bare baserer på team
        , CASE
            WHEN k8s_namespace in (select team from `nais_billing_regional.nais_teams`) and not starts_with(k8s_namespace, 'nais') THEN 'Produktteam'
            WHEN starts_with(team, 'nais') THEN 'Plattform'
            WHEN team in ('nada', 'dataplattform') THEN 'Dataplattform'
            WHEN team = 'isoc' THEN 'ISOC/SecOps'
            WHEN (project_name LIKE '%-dev' OR project_name LIKE '%-prod') THEN 'Produktteam'
            ELSE 'Annet'
        END AS cost_category
        , DATE(usage_start_time) AS dato
        , service_description
        , sku_id
        , sku_description
        , (SUM(CAST(cost * 1000000 AS int64)) + SUM(IFNULL((
                                                                SELECT
                                                                    SUM(IF(c.type not in ('COMMITTED_USAGE_DISCOUNT', 'COMMITTED_USAGE_DISCOUNT_DOLLAR_BASE'), CAST(c.amount * 1000000 AS int64), 0))
                                                                FROM
                                                                    UNNEST(credits) c),
                                                            0))) / 1000000
    AS calculated_cost

FROM `nais-io.nais_billing_regional.gcp_billing_export`

WHERE k8s_namespace IS NOT NULL -- Betyr at det er en GKE-kostnad
    -- CUD som ikke fordeles på team. Inkluderes ved å ikke trekke fra CUD-credits i stedet
    AND sku_id NOT IN ('08CF-4B12-9DDF', 'F61D-4D51-AAFC', '624A-C99D-23C4', '7EAE-342B-753C')

GROUP BY project_name, project_id, env, tenant, team, dato, service_description, sku_id, sku_description, app, cost_category, namespace, cluster
