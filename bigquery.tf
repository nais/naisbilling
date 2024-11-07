resource "google_bigquery_dataset" "nais_billing_regional" {
  dataset_id = "nais_billing_regional"
  friendly_name = "nais_billing_regional"
  description = "Billing distibuted to teams and apps. Pretends Commited Use Discounts do not exist. Managed by terraform in nais/naisbilling"
  location = "europe-north1"
}

resource "google_bigquery_dataset" "nais_billing_extended" {
  dataset_id = "nais_billing_extended"
  friendly_name = "nais_billing_extended"
  description = "The main difference between this dataset and nais_billing_regional is the additional fields regarding usage, price, cost and credits. It does also not contain data from before March 7th 2023. Managed by terraform in nais/naisbilling. "
  location = "europe-north1"
}

resource "google_bigquery_dataset" "legacy_billing" {
  dataset_id = "legacy_billing"
  friendly_name = "legacy_billing"
  description = "Contains data for historic billing. Merged with new data in nais_billing_regional.cost_breakdown_total. Managed by terraform in nais/naisbilling"
  location = "europe-north1"
}

resource "google_bigquery_table" "legacy_excluding_nais" {
  dataset_id  = google_bigquery_dataset.legacy_billing.dataset_id
  table_id    = "cost_breakdown_excluding_nais"
  description = "Billing from gcp for all projects excluding nais clusters as there is a separate logic for cost allocation in kubernetes"

  view {
    query          = file("views/legacy_billing/cost_breakdown_excluding_nais.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "legacy_including_nais" {
  dataset_id  = google_bigquery_dataset.legacy_billing.dataset_id
  table_id    = "cost_breakdown_nais"
  description = "Billing for nais clusters allocated to namespaces and applications"

  view {
    query          = file("views/legacy_billing/cost_breakdown_nais.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "legacy_total" {
  dataset_id  = google_bigquery_dataset.legacy_billing.dataset_id
  table_id    = "cost_breakdown_total_gcp"
  description = "Combines all gcp billing"

  view {
    query          = file("views/legacy_billing/cost_breakdown_total_gcp.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "legacy_export" {
  dataset_id  = google_bigquery_dataset.legacy_billing.dataset_id
  table_id    = "gcp_billing_export"
  description = "Combines gcp billing from different points in time"

  view {
    query          = file("views/legacy_billing/gcp_billing_export.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "legacy_projects" {
  dataset_id  = google_bigquery_dataset.legacy_billing.dataset_id
  table_id    = "gcp_projects_derived"
  description = "Data cleansing for gcp projects table"

  view {
    query          = file("views/legacy_billing/gcp_projects_derived.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "extended_export" {
  dataset_id  = google_bigquery_dataset.nais_billing_extended.dataset_id
  table_id    = "billing_export"
  description = "Unnests repeated fields from the billing export"

  view {
    query          = file("views/nais_billing_extended/billing_export.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "extended_excluding_gke" {
  dataset_id  = google_bigquery_dataset.nais_billing_extended.dataset_id
  table_id    = "breakdown_excluding_gke"
  description = "Breaks down all costs not related to gke"

  view {
    query          = file("views/nais_billing_extended/breakdown_excluding_gke.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "extended_gke" {
  dataset_id  = google_bigquery_dataset.nais_billing_extended.dataset_id
  table_id    = "breakdown_gke"
  description = "Breaks down all costs related to gke"

  view {
    query          = file("views/nais_billing_extended/breakdown_gke.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "extended_total" {
  dataset_id  = google_bigquery_dataset.nais_billing_extended.dataset_id
  table_id    = "breakdown_total"
  description = "Combines costs from breakdown_gke, breakdown_excluding_gke and google marketplace (from nais-analyse project)"

  view {
    query          = file("views/nais_billing_extended/breakdown_total.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "extended_nav" {
  dataset_id  = google_bigquery_dataset.nais_billing_extended.dataset_id
  table_id    = "tenant_nav"
  description = "Total costs for nav tenant + nais"

  view {
    query          = file("views/nais_billing_extended/tenant_nav.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "extended_fhi" {
  dataset_id  = google_bigquery_dataset.nais_billing_extended.dataset_id
  table_id    = "tenant_fhi"
  description = "Total costs for fhi tenant"

  view {
    query          = file("views/nais_billing_extended/tenant_fhi.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "extended_ssb" {
  dataset_id  = google_bigquery_dataset.nais_billing_extended.dataset_id
  table_id    = "tenant_ssb"
  description = "Total costs for ssb tenant"

  view {
    query          = file("views/nais_billing_extended/tenant_ssb.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "extended_mtpilot" {
  dataset_id  = google_bigquery_dataset.nais_billing_extended.dataset_id
  table_id    = "tenant_mtpilot"
  description = "Total costs for mtpilot tenant"

  view {
    query          = file("views/nais_billing_extended/tenant_mtpilot.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "regional_aiven" {
  dataset_id  = google_bigquery_dataset.nais_billing_regional.dataset_id
  table_id    = "cost_breakdown_aiven"
  description = "Aiven cost extrapolated to daily from monthly cost"

  view {
    query          = file("views/nais_billing_regional/cost_breakdown_aiven.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "regional_aiven_nav" {
  dataset_id  = google_bigquery_dataset.nais_billing_regional.dataset_id
  table_id    = "cost_breakdown_aiven_nav"
  description = "Aiven cost extrapolated to daily from monthly cost for nav tenant"

  view {
    query          = file("views/nais_billing_regional/cost_breakdown_aiven_nav.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "regional_excluding_nais" {
  dataset_id  = google_bigquery_dataset.nais_billing_regional.dataset_id
  table_id    = "cost_breakdown_excluding_nais"
  description = "Breakdown of non-gke costs"

  view {
    query          = file("views/nais_billing_regional/cost_breakdown_excluding_nais.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "regional_nais" {
  dataset_id  = google_bigquery_dataset.nais_billing_regional.dataset_id
  table_id    = "cost_breakdown_nais"
  description = "Breakdown of costs for all gke clusters"

  view {
    query          = file("views/nais_billing_regional/cost_breakdown_nais.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "regional_total" {
  dataset_id  = google_bigquery_dataset.nais_billing_regional.dataset_id
  table_id    = "cost_breakdown_total"
  description = "Combines all sources of gcp billing"

  view {
    query          = file("views/nais_billing_regional/cost_breakdown_total.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "regional_export" {
  dataset_id  = google_bigquery_dataset.nais_billing_regional.dataset_id
  table_id    = "gcp_billing_export"
  description = "Combines and unpacks gcp billing from different points in time"

  view {
    query          = file("views/nais_billing_regional/gcp_billing_export.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "regional_teams" {
  dataset_id  = google_bigquery_dataset.nais_billing_regional.dataset_id
  table_id    = "nais_teams"
  description = "List of all teams and tenants that were ever billed in gcp"

  view {
    query          = file("views/nais_billing_regional/nais_teams.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "regional_fhi" {
  dataset_id  = google_bigquery_dataset.nais_billing_regional.dataset_id
  table_id    = "tenant_fhi"
  description = "The parts of the cost breakdown that belong to the fhi tenant"

  view {
    query          = file("views/nais_billing_regional/tenant_fhi.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "regional_mtpilot" {
  dataset_id  = google_bigquery_dataset.nais_billing_regional.dataset_id
  table_id    = "tenant_mtpilot"
  description = "The parts of the cost breakdown that belong to the mtpilot tenant"

  view {
    query          = file("views/nais_billing_regional/tenant_mtpilot.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "regional_nav" {
  dataset_id  = google_bigquery_dataset.nais_billing_regional.dataset_id
  table_id    = "tenant_nav"
  description = "The parts of the cost breakdown that belong to the nav tenant"

  view {
    query          = file("views/nais_billing_regional/tenant_nav.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "regional_ssb" {
  dataset_id  = google_bigquery_dataset.nais_billing_regional.dataset_id
  table_id    = "tenant_ssb"
  description = "The parts of the cost breakdown that belong to the ssb tenant"

  view {
    query          = file("views/nais_billing_regional/tenant_ssb.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "source_ssb" {
  dataset_id  = google_bigquery_dataset.nais_billing_regional.dataset_id
  table_id    = "source_ssb"
  description = "The part of the source data that belongs to the ssb tenant"

  view {
    query          = file("views/nais_billing_regional/source_ssb.sql")
    use_legacy_sql = false
  }
}


