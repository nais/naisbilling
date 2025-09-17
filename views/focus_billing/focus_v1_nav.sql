SELECT
    *,
    _PARTITIONDATE AS partition_date
FROM
    `nais-io.gcp_billing_immutable_014686_D32BB4_68DF8E_eu.gcp_billing_export_focus_014686_D32BB4_68DF8E`
WHERE
    (
        SELECT
            a.displayname
        FROM
            UNNEST (x_project.ancestors) a
        WHERE
            STARTS_WITH(a.resourcename, "organizations")
    ) IN (
        'nav.no',
        'dev-nais-io',
        'nais.io',
        'test-nais.io',
        'ci-nais.io',
        NULL
    )