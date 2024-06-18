SELECT distinct team, tenant FROM `nais-io.nais_billing_regional.gcp_billing_export`
where team is not null or tenant is not null