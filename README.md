# naisbilling
Terraform for billing i BigQuery

I [views](views) er det en mappe per BigQuery dataset. Hver mappe inneholder SQL-filer som lager views i datasettet.

## Slik flyter kostnadsdataene (hvem leser hva)

```text
GCP detaljert billing-eksport (Nais-io, Novari, KS Digital)
  → view `nais_billing_regional.gcp_billing_export` (UNION ALL av eksportene)
  → views `cost_breakdown_excluding_nais` / `cost_breakdown_nais`
  → scheduled query "every day 05:30" (SA: nais-io-bigquery-schedule-user)
      → tabell `nais_billing_regional.cost_breakdown_total_daily_update`
        (rullerende 10-dagers patch; full rebuild den 1. i måneden)
  → view `console.source_cost` (nais-io-terraform-modules, modules/base/console.tf)
  → view `console.cost_<tenant>` (nais-terraform-modules, modules/management/bigquery_views)
      – omdøper env, ekskluderer 'Support', deler ut CloudNativePG, `dato <= CURRENT_DATE - 2`
  → nais/api (`internal/cost/costupdater`): syncer siste 5 dager til Postgres hver time,
      serverer GraphQL (`team.cost.daily`, `costMonthlySummary`, …)
  → console-frontend viser dataene (alle spørringer bruker `to = i dag - 2`)
```

## legacy_billing

Disse viewene er ikke direkte i bruk, men ble brukt for å lage tabellen `cost_breakdown_total_gcp_static` som er grunnlaget for historisk data fra gcp (fram til 2023-03-07). Tilsvarer https://github.com/nais/navbilling/tree/main/views.

## nais_billing_regional

Dette datasettet er mest brukt. Det har en stor svakhet og det er at det ikke tar høyde for verken kostnaden eller rabatter tilknyttet "commited use discounts" (cud). Det er fordi det er vanskelig å fordele disse kostnadene på team. Derfor er kostnadene som vises her litt høyere enn de faktiske kostnadene (som om vi ikke hadde noen cud-avtaler).

## nais_billing_extended

Ligner veldig på nais_billing_regional, men inkluderer ekstra felter med rabatter, priser og forbruk. Her tar vi høyde for cud-avtaler, men det hindrer oss fra å fordele disse kostnadene på team. Dette datasettet bør brukes dersom det er viktig med nøyaktige tall.

## How to import manually created views to terraform
In order to let terraform manage views that have been manually created in the google cloud console, you need to import them to the terraform state.
This needs to be done locally and is not part of the github action.

1. Install terraform.
2. Create a new key for service account `nais-billing-bigquery-ci-cd@nais-io.iam.gserviceaccount.com` and download as json.
3. Run `export GOOGLE_CREDENTIALS=<JSON_FILE_NAME.json>`.
4. Add the view definition to `views/<view name>.sql`.
5. Add dataset and view as resources in `bigquery.tf` referring to view definition from step 4.
6. Run `terraform init`.
7. If dataset is not already imported, run `terraform import google_bigquery_dataset.<terraform id of dataset> <dataset name>`.
8. Run `terraform import google_bigquery_table.<terraform id of view> <dataset name>/<view name>`.
