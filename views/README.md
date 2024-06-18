# Nais billing views

Det er en mappe per BigQuery dataset. Hver mappe inneholder SQL-filer som lager views i datasettet.

## legacy_billing

Disse viewene er ikke direkte i bruk, men ble brukt for å lage tabellen `cost_breakdown_total_gcp_static` som er grunnlaget for historisk data fra gcp (fram til 2023-03-07). Tilsvarer https://github.com/nais/navbilling/tree/main/views.

## nais_billing_regional

Dette datasettet er mest brukt. Det har en stor svakhet og det er at det ikke tar høyde for verken kostnaden eller rabatter tilknyttet "commited use discounts" (cud). Det er fordi det er vanskelig å fordele disse kostnadene på team. Derfor er kostnadene som vises her litt høyere enn de faktiske kostnadene (som om vi ikke hadde noen cud-avtaler).

## nais_billing_extended

Ligner veldig på nais_billing_regional, men inkluderer ekstra felter med rabatter, priser og forbruk. Her tar vi høyde for cud-avtaler, men det hindrer oss fra å fordele disse kostnadene på team. Dette datasettet bør brukes dersom det er viktig med nøyaktige tall.