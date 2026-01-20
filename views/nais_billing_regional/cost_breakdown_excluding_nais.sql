SELECT
    project_name,
    project_id,
    env,
    IFNULL(team_label, team) AS team,
    COALESCE(tenant, 'nav') AS tenant,
    app_label AS app,
    CASE
        WHEN STARTS_WITH(team, 'nais') THEN 'Plattform'
        WHEN team IN ('nada', 'knada-gcp', 'knada-dev') THEN 'Dataplattform'
        WHEN team = 'isoc' THEN 'ISOC/SecOps'
        WHEN (
            project_name LIKE '%-dev'
            OR project_name LIKE '%-prod'
        ) THEN 'Produktteam'
        ELSE 'Annet'
    END AS cost_category,
    DATE(usage_start_time) AS dato,
    service_description,
    sku_id,
    sku_description,
    CASE
        WHEN service_description IN ("Cloud SQL", "Cloud Storage") THEN resource_name
        ELSE NULL
    END AS resource_name,
    (
        SUM(CAST(cost AS NUMERIC)) + SUM(
            IFNULL(
                (
                    SELECT
                        SUM(
                         CAST(c.amount AS NUMERIC)
                            )
                    FROM
                        UNNEST (credits) c WHERE c.type NOT IN (
                                    'COMMITTED_USAGE_DISCOUNT',
                                    'COMMITTED_USAGE_DISCOUNT_DOLLAR_BASE'
                                )
                ),
                0
            )
        )
    ) AS calculated_cost
FROM
    `nais-io.nais_billing_regional.gcp_billing_export`
WHERE
    k8s_namespace IS NULL -- Betyr at det ikke er en GKE-kostnad
    -- CUD som ikke fordeles på team. Inkluderes ved å ikke trekke fra CUD-credits i stedet
    AND sku_id NOT IN (
        '08CF-4B12-9DDF',
        'F61D-4D51-AAFC',
        '624A-C99D-23C4',
        '7EAE-342B-753C'
    )
GROUP BY
    project_name,
    project_id,
    env,
    tenant,
    team,
    dato,
    service_description,
    sku_id,
    sku_description,
    resource_name,
    app,
    cost_category