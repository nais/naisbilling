SELECT
    project.name project_name,
    project.id project_id,
    service.description service_description,
    sku.id sku_id,
    sku.description sku_description,
    usage_start_time,
    usage_end_time,
    usage.amount usage_amount,
    usage.unit usage_unit,
    cost,
    credits,
    labels
FROM `nais-analyse-prod-2dcc.navbilling.gcp_billing_export_v1_0184D6_470198_7FFA56`
UNION ALL
SELECT
    project.name project_name,
    project.id project_id,
    service.description service_description,
    sku.id sku_id,
    sku.description sku_description,
    usage_start_time,
    usage_end_time,
    usage.amount usage_amount,
    usage.unit usage_unit,
    cost,
    credits,
    labels

FROM `nais-analyse-prod-2dcc.navbilling.gcp_billing_export_v1_history`
UNION ALL
SELECT
    project.name project_name,
    project.id project_id,
    service.description service_description,
    sku.id sku_id,
    sku.description sku_description,
    usage_start_time,
    usage_end_time,
    usage.amount usage_amount,
    usage.unit usage_unit,
    cost,
    credits,
    labels
FROM `nais-analyse-prod-2dcc.navbilling.gcp_billing_export_v1_014686_D32BB4_68DF8E`