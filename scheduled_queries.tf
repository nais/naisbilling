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
    query                           = file("scheduled_queries/regional_daily_cost_update.sql")
  }
}

resource "google_bigquery_data_transfer_config" "tenant_monthly" {
  location                  = "europe-north1"
  data_source_id            = "scheduled_query"
  display_name              = "Monthly update of monthly_tenant_billing"
  destination_dataset_id    = google_bigquery_dataset.tenant_billing.dataset_id
  schedule                  = "3 of month 03:15"
  service_account_name      = "nais-io-bigquery-schedule-user@nais-io.iam.gserviceaccount.com"
  email_preferences {
    enable_failure_email = true
  }

  params = {
    destination_table_name_template = "monthly_tenant_billing"
    write_disposition               = "WRITE_TRUNCATE"
    query                           = file("scheduled_queries/tenant_monthly.sql")
  }
}

resource "google_bigquery_data_transfer_config" "nais_teams_daily_update" {
  location                  = "europe-north1"
  data_source_id            = "scheduled_query"
  display_name              = "Daily update of nais_teams_history"
  destination_dataset_id    = google_bigquery_dataset.nais_billing_regional.dataset_id
  schedule                  = "every day 03:00"
  service_account_name      = "nais-io-bigquery-schedule-user@nais-io.iam.gserviceaccount.com"
  email_preferences {
    enable_failure_email = true
  }

  params = {
    query = file("scheduled_queries/nais_teams_daily_update.sql")
  }
}