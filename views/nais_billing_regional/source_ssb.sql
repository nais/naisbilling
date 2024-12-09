SELECT
    *,
    _PARTITIONDATE as partion_date
FROM
    `nais-io.nais_billing_regional.gcp_billing_export_resource_v1_014686_D32BB4_68DF8E`
where
    EXISTS (
        SELECT
            1
        FROM
            UNNEST (project.ancestors) as a
        WHERE
            STARTS_WITH(a.resource_name, 'organizations/')
            AND a.display_name = 'ssb.no'
    )