SELECT
    *,
    _PARTITIONDATE AS partition_date
FROM
    `nais-io.nais_billing_regional.gcp_billing_export_resource_v1_014686_D32BB4_68DF8E`
WHERE
    (
        SELECT
            a.display_name
        FROM
            UNNEST (project.ancestors) a
        WHERE
            STARTS_WITH(a.resource_name, "organizations/")
    ) IN (
        'nav.no',
        'nais.io',
        'dev-nais.io',
        'ci-nais.io',
        'test-nais.no'
    )
    OR (
        SELECT
            a.display_name
        FROM
            UNNEST (project.ancestors) a
        WHERE
            STARTS_WITH(a.resource_name, "organizations/")
    ) IS NULL