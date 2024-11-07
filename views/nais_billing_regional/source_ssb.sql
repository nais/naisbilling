SELECT *
FROM `nais-io.nais_billing_regional.gcp_billing_export_resource_v1_014686_D32BB4_68DF8E` 
where (SELECT value from UNNEST(project.labels) WHERE key='tenant') = 'ssb'