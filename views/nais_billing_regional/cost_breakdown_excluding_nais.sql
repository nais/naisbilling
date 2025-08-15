SELECT project_name 
        , project_id
        , env
        , IFNULL(team_label, team) as team
        , COALESCE(tenant, 'nav') as tenant
        , app_label as app
        , CASE
            WHEN starts_with(team, 'nais') THEN 'Plattform'
            WHEN team in ('nada', 'knada-gcp', 'knada-dev') THEN 'Dataplattform'
            WHEN team = 'isoc' THEN 'ISOC/SecOps'
            WHEN (project_name LIKE '%-dev' OR project_name LIKE '%-prod') THEN 'Produktteam'
            ELSE 'Annet'
        END AS cost_category
        , DATE(usage_start_time) AS dato
        , service_description
        , sku_id
        , sku_description
        , CASE
            WHEN service_description in ("Cloud SQL", "Cloud Storage")
            THEN resource_name
            ELSE null
        END as resource_name
        , (SUM(CAST(cost * 1000000 AS int64)) + SUM(IFNULL((
                                                                SELECT
                                                                    SUM(IF(c.type not in ('COMMITTED_USAGE_DISCOUNT', 'COMMITTED_USAGE_DISCOUNT_DOLLAR_BASE'), CAST(c.amount * 1000000 AS int64), 0))
                                                                FROM
                                                                    UNNEST(credits) c),
                                                            0))) / 1000000
    AS calculated_cost

FROM `nais-io.nais_billing_regional.gcp_billing_export`

WHERE k8s_namespace IS NULL -- Betyr at det ikke er en GKE-kostnad
  -- CUD som ikke fordeles på team. Inkluderes ved å ikke trekke fra CUD-credits i stedet
  AND sku_id NOT IN ('08CF-4B12-9DDF', 'F61D-4D51-AAFC', '624A-C99D-23C4', '7EAE-342B-753C')

GROUP BY project_name, project_id, env, tenant, team, dato, service_description, sku_id, sku_description, resource_name, app, cost_category
