(
    WITH usage AS
             (
                 SELECT 'nais-prod' AS cluster
                      , namespace
                      , (select value from unnest(labels) where key='app') as app
                      , sku_id
                      , PARSE_DATE('%Y%m%d', usage_start_time) AS dato
                      , SUM(cost) AS sum_cost
                      , SUM(SUM(cost)) OVER (PARTITION BY sku_id, usage_start_time) AS sum_cost_per_sku
                      --,sum(cost_with_unallocated_untracked) as sum_cost_with_unallocated_untracked
                 FROM `nais-io.legacy_gke_usage.nais-prod-020f`
                 GROUP BY cluster, namespace, sku_id, usage_start_time, app

                 UNION ALL

                 SELECT 'nais-dev' AS cluster
                      , namespace
                      , (select value from unnest(labels) where key='app') as app
                      , sku_id
                      , PARSE_DATE('%Y%m%d', usage_start_time) AS dato
                      , SUM(cost) AS sum_cost
                      , SUM(SUM(cost)) OVER (PARTITION BY sku_id, usage_start_time) AS sum_cost_per_sku
                      --,sum(cost_with_unallocated_untracked) as sum_cost_with_unallocated_untracked
                 FROM `nais-io.legacy_gke_usage.nais-dev-2e7b`
                 GROUP BY cluster, namespace, sku_id, usage_start_time, app

                 UNION ALL

                 SELECT 'nais-labs' AS cluster
                      , namespace
                      , (select value from unnest(labels) where key='app') as app
                      , sku_id
                      , PARSE_DATE('%Y%m%d', usage_start_time) AS dato
                      , SUM(cost) AS sum_cost
                      , SUM(SUM(cost)) OVER (PARTITION BY sku_id, usage_start_time) AS sum_cost_per_sku
                      --,sum(cost_with_unallocated_untracked) as sum_cost_with_unallocated_untracked
                 FROM `nais-io.legacy_gke_usage.nais-labs-ebde`
                 GROUP BY cluster, namespace, sku_id, usage_start_time, app
             ),

         usage_share AS (
             select cluster
                  , namespace
                  , app
                  , sku_id
                  , dato
                  , sum_cost
                  , sum_cost_per_sku
                  , SAFE_DIVIDE(sum_cost, sum_cost_per_sku) AS Andel
             FROM usage
         ),

         billing AS (
             SELECT project_name AS project_name
                  , project_id
                  , sku_id
                  , sku_description
                  , service_description
                  , DATE(usage_start_time, 'US/Pacific') AS dato
                  , (SUM(CAST(cost * 1000000 AS int64)) + SUM(IFNULL((
                                                                         SELECT
                                                                             SUM(IF(c.type != 'COMMITTED_USAGE_DISCOUNT_DOLLAR_BASE', CAST(c.amount * 1000000 AS int64), 0))
                                                                         FROM
                                                                             UNNEST(credits) c),
                                                                     0))) / 1000000 AS total
             FROM `nais-io.legacy_billing.gcp_billing_export_legacy`
                  -- kostnader for disse tre prosjektene skal særbehandles
             WHERE project_id IN ('nais-dev-2e7b', 'nais-labs-ebde', 'nais-prod-020f')
                  -- CUD som ikke fordeles på team. Inkluderes ved å ikke trekke fra CUD-credits i stedet
               AND sku_id NOT IN ('08CF-4B12-9DDF', 'F61D-4D51-AAFC')
             GROUP BY 1,2,3,4,5,6
         )

    SELECT u.cluster
         , b.project_name
         , u.namespace
         , CASE
               WHEN (b.project_name = 'nais-dev') THEN 'dev'
               WHEN (b.project_name = 'nais-labs') THEN 'labs'
               WHEN (b.project_name = 'nais-prod') THEN 'prod'
        END AS env
         , t.team
         , COALESCE(p.tenant, 'nav') as tenant
         , u.app
         , CASE
               WHEN t.team IS NULL then 'Plattform'
               ELSE 'Produktteam'
        END AS cost_category
         , b.dato
         , b.service_description
         , b.sku_id
         , b.sku_description
         , COALESCE(u.andel, 1) * b.total AS calculated_cost

    FROM billing b

             LEFT JOIN usage_share u
                       ON b.project_name = u.cluster
                           AND b.sku_id = u.sku_id
                           AND b.dato = u.dato

             LEFT JOIN `nais-io.legacy_billing.nais_teams` t
                       ON u.namespace = t.team

             LEFT JOIN `nais-io.legacy_billing.gcp_projects` p
                       ON b.project_id = p.project_id
)