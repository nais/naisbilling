SELECT
    project_name,
    project_id,
    CASE
        WHEN env IS NULL THEN CASE
            WHEN project_name LIKE '%-dev' THEN 'dev'
            WHEN project_name LIKE '%-prod' THEN 'prod'
            WHEN project_name LIKE '%-ci' THEN 'ci'
            ELSE NULL
        END
        ELSE env
    END AS env,
    k8s_cluster AS cluster,
    k8s_namespace AS namespace,
    CASE
        WHEN k8s_namespace = 'kube-system' THEN team -- kube-system finnes i nais_teams_history
        WHEN k8s_namespace IN (
            SELECT
                team
            FROM
                `nais_billing_regional.nais_teams_history`
        )
        AND NOT STARTS_WITH(k8s_namespace, 'nais') THEN k8s_namespace
        WHEN project_name IN ('knada-gcp', 'knada-dev') AND STARTS_WITH(k8s_namespace, 'team-') THEN k8s_namespace
        ELSE COALESCE(team, 'nais')
    END AS team,
    COALESCE(tenant, 'nav') AS tenant,
    COALESCE(k8s_app, app_label) AS app,
    -- cost_category vil ikke fordele GKE-kostnader hvis vi bare baserer på team
    CASE
        WHEN k8s_namespace IN (
            SELECT
                team
            FROM
                `nais_billing_regional.nais_teams_history`
        )
        AND NOT STARTS_WITH(k8s_namespace, 'nais') THEN 'Produktteam'
        WHEN STARTS_WITH(team, 'nais') THEN 'Plattform'
        WHEN team IN ('nada', 'dataplattform') THEN 'Dataplattform'
        WHEN team = 'isoc' THEN 'ISOC/SecOps'
        WHEN (
            project_name LIKE '%-dev'
            OR project_name LIKE '%-prod'
        ) THEN 'Produktteam'
        ELSE 'Annet'
    END AS cost_category,
    DATE(usage_start_time, 'Europe/Oslo') AS dato,
    service_description,
    sku_id,
    sku_description,
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
    ) AS calculated_cost,
    partition_date
FROM
    `nais-io.nais_billing_regional.gcp_billing_export`
WHERE
    k8s_namespace IS NOT NULL -- Betyr at det er en GKE-kostnad
    -- CUD som ikke fordeles på team. Inkluderes ved å ikke trekke fra CUD-credits i stedet
    -- Dette gjelder resource based CUDs og den gamle versjonen av spend based CUDs (før februar 2026)
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
    app,
    cost_category,
    namespace,
    cluster,
    partition_date