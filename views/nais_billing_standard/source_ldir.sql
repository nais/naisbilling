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
)
WHERE
    EXISTS (
        SELECT 1
        FROM UNNEST(project.ancestors) as a
        WHERE STARTS_WITH(a.resource_name, 'organizations/') AND a.display_name = 'landbruksdirektoratet.no'
    )
