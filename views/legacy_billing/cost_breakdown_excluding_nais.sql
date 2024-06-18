(
    SELECT b.project_name
         , p.environment as env
         , p.team
         , COALESCE(p.tenant, 'nav') as tenant
         , (SELECT value from UNNEST(labels) WHERE key='app') as app
         , CASE
               WHEN p.team = 'nais' THEN 'Plattform'
               WHEN p.team = 'nada' THEN 'Dataplattform'
               WHEN p.team = 'isoc' THEN 'ISOC'
               WHEN (b.project_name LIKE '%-dev' OR b.project_name LIKE '%-prod') THEN 'Produktteam'
               ELSE 'Annet'
        END AS cost_category
         , DATE(b.usage_start_time) AS dato
         , b.service_description
         , b.sku_id
         , b.sku_description
         , (SUM(CAST(b.cost * 1000000 AS int64)) + SUM(IFNULL((
                                                                  SELECT
                                                                      SUM(IF(c.type != 'COMMITTED_USAGE_DISCOUNT_DOLLAR_BASE', CAST(c.amount * 1000000 AS int64), 0))
                                                                  FROM
                                                                      UNNEST(credits) c),
                                                              0))) / 1000000
        AS calculated_cost

    FROM `nais-io.legacy_billing.gcp_billing_export_legacy` b

             LEFT JOIN `nais-io.legacy_billing.gcp_projects_derived` p
                       ON b.project_id = p.project_id

    WHERE (b.project_id NOT IN ('nais-dev-2e7b', 'nais-labs-ebde', 'nais-prod-020f')
        OR b.project_name IS NULL)
        -- CUD som ikke fordeles på team. Inkluderes ved å ikke trekke fra CUD-credits i stedet
        AND b.sku_id NOT IN ('08CF-4B12-9DDF', 'F61D-4D51-AAFC')


    GROUP BY project_name, env, team, cost_category, dato, service_description, sku_id, sku_description, app, tenant
)