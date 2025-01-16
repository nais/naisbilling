SELECT
    *
FROM (
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
        _PARTITIONDATE as partition_date
    FROM
        `nais-io.nais_billing_standard.gcp_billing_export_v1_014686_D32BB4_68DF8E`
    WHERE usage_start_time > '2025-01-12 14:00:00' --Tidspunktet som gir best overlapp. Mister ca €0.4
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
        _PARTITIONDATE as partition_date
    FROM
        `nais-io.nais_billing_standard.gcp_billing_export_v1_014686_D32BB4_68DF8E_copy`
    WHERE _PARTITIONDATE >= '2023-01-01' --Første kostnad for ssb var tidlig i 2023
    AND usage_start_time <= '2025-01-12 14:00:00'

)
WHERE
    EXISTS (
        SELECT 1
        FROM UNNEST(project.ancestors) as a
        WHERE STARTS_WITH(a.resource_name, 'organizations/') AND a.display_name = 'ssb.no'
    )
