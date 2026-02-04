WITH
    base AS (
        SELECT
            billing_account_id,
            service,
            sku,
            usage_start_time,
            usage_end_time,
            project,
            labels,
            system_labels,
            location,
            tags,
            transaction_type,
            seller_name,
            export_time,
            cost,
            currency,
            currency_conversion_rate,
            usage,
            credits,
            invoice,
            cost_type,
            adjustment_info,
            cost_at_list,
            _PARTITIONDATE AS partition_date
        FROM
            `nais-io.nais_billing_standard.gcp_billing_export_v1_014686_D32BB4_68DF8E`
        UNION ALL
        SELECT
            billing_account_id,
            service,
            sku,
            usage_start_time,
            usage_end_time,
            project,
            labels,
            system_labels,
            location,
            tags,
            transaction_type,
            seller_name,
            export_time,
            cost,
            currency,
            currency_conversion_rate,
            usage,
            credits,
            invoice,
            cost_type,
            adjustment_info,
            cost_at_list,
            _PARTITIONDATE AS partition_date
        FROM
            `nais-io.nais_billing_standard.gcp_billing_export_v1_014686_D32BB4_68DF8E_copy`
    )
SELECT
    *
FROM
    base
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