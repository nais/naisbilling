# resource "google_service_account" "bigquery-schedule-user" {
#   account_id   = "nais-io-bigquery-schedule-user"
#   display_name = "Nada IAM service account for federated queries"
#   description = "Runs scheduled queries to update BiqQuery tables. Managed by terraform in navikt/naisbilling"
# }

resource "google_bigquery_data_transfer_config" "extended_daily_cost_update" {
  location                  = "europe-north1"
  data_source_id            = "scheduled_query"
  display_name              = "Daily update for extended breakdown_total"
  destination_dataset_id    = google_bigquery_dataset.nais_billing_extended.dataset_id
  schedule                  = "every day 04:00"
  service_account_name      = "nais-io-bigquery-schedule-user@nais-io.iam.gserviceaccount.com"
  email_preferences {
    enable_failure_email = true
  }

  schedule_options {
    start_time = "2024-06-05T04:00:00Z" 
  }

  params = {
    destination_table_name_template = "breakdown_total_daily"
    partitioning_field              = "dato"
    write_disposition               = "WRITE_TRUNCATE"
    query                           = "SELECT * FROM `nais-io.nais_billing_extended.breakdown_total`"
  }
}

resource "google_bigquery_data_transfer_config" "regional_daily_cost_update" {
  location                  = "europe-north1"
  data_source_id            = "scheduled_query"
  display_name              = "Daily update for regional cost_breakdown_total"
  destination_dataset_id    = google_bigquery_dataset.nais_billing_regional.dataset_id
  schedule                  = "every day 05:30"
  service_account_name      = "nais-io-bigquery-schedule-user@nais-io.iam.gserviceaccount.com"
  email_preferences {
    enable_failure_email = true
  }

  params = {
    destination_table_name_template = "cost_breakdown_total_daily_update"
    partitioning_field              = "dato"
    write_disposition               = "WRITE_TRUNCATE"
    query                           = "SELECT * FROM `nais-io.nais_billing_regional.cost_breakdown_total`"
  }
}