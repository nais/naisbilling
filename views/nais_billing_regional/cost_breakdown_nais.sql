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
        , case -- Slettede team lables som nais fordi nais_billing_regional.nais_teams ikke har historikk
            when b.k8s_namespace in (select team from `nais_billing_regional.nais_teams`) and not starts_with(b.k8s_namespace, 'nais') then b.k8s_namespace
            when b.project_name in ('knada-gcp', 'knada-dev') then b.k8s_namespace
            else b.team 
        end as team
        , COALESCE(b.tenant, 'nav') as tenant
        , COALESCE(b.k8s_app, app_label) as app
        -- cost_category vil ikke fordele GKE-kostnader hvis vi bare baserer på b.team
        , CASE
            WHEN b.k8s_namespace in (select team from `nais_billing_regional.nais_teams`) and not starts_with(b.k8s_namespace, 'nais') THEN 'Produktteam'
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
        , (SUM(CAST(b.cost * 1000000 AS int64)) + SUM(IFNULL((
                                                                SELECT
                                                                    SUM(IF(c.type not in ('COMMITTED_USAGE_DISCOUNT', 'COMMITTED_USAGE_DISCOUNT_DOLLAR_BASE'), CAST(c.amount * 1000000 AS int64), 0))
                                                                FROM
                                                                    UNNEST(credits) c),
                                                            0))) / 1000000
    AS calculated_cost

FROM `nais-io.nais_billing_regional.gcp_billing_export` b

WHERE b.k8s_namespace IS NOT NULL -- Betyr at det er en GKE-kostnad
    -- CUD som ikke fordeles på team. Inkluderes ved å ikke trekke fra CUD-credits i stedet
    AND b.sku_id NOT IN ('08CF-4B12-9DDF', 'F61D-4D51-AAFC', '624A-C99D-23C4', '7EAE-342B-753C')

GROUP BY project_name, project_id, env, tenant, team, dato, service_description, sku_id, sku_description, app, cost_category, namespace, cluster
