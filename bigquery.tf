resource "google_bigquery_dataset" "nais_billing_regional" {
  dataset_id = "nais_billing_regional"
  friendly_name = "nais_billing_regional"
  description = "Billing distibuted to teams and apps. Pretends Commited Use Discounts do not exist. Managed by terraform in nais/nais-io-terraform-modules"
  location = "europe-north1"
}

resource "google_bigquery_dataset" "nais_billing_extended" {
  dataset_id = "nais_billing_extended"
  friendly_name = "nais_billing_extended"
  description = "The main difference between this dataset and nais_billing_regional is the additional fields regarding usage, price, cost and credits. It does also not contain data from before March 7th 2023. Managed by terraform in nais/nais-io-terraform-modules. "
  location = "europe-north1"
}

resource "google_bigquery_dataset" "legacy_billing" {
  dataset_id = "legacy_billing"
  friendly_name = "legacy_billing"
  description = "Contains data for historic billing. Merged with new data in nais_billing_regional.cost_breakdown_total. Managed by terraform in nais/nais-io-terraform-modules"
  location = "europe-north1"
}
