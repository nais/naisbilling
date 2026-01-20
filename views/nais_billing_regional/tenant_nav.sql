SELECT
    *
FROM
    `nais-io.nais_billing_regional.cost_breakdown_total_daily_update`
WHERE
    tenant IN (
        'nav',
        'example',
        'testing',
        'nais-dev',
        'dev-nais',
        'nais',
        'ci-nais'
    )