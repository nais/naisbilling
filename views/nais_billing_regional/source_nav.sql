SELECT
    *,
    _PARTITIONDATE AS partition_date
FROM
    `nais-io.nais_billing_regional.gcp_billing_export_resource_v1_014686_D32BB4_68DF8E`
WHERE
    (select a.display_name from unnest(project.ancestors) a where starts_with(a.resource_name, "organizations/")) 
        in ('nav.no', 'nais.io', 'dev-nais.io', 'ci-nais.io', 'test-nais.no')
    OR (select a.display_name from unnest(project.ancestors) a where starts_with(a.resource_name, "organizations/")) IS NULL