terraform {
  backend "gcs" {
    bucket = "nais-billing-terraform"
    prefix = "state"
  }
}

provider "google" {
  project = "nais-io"
  region  = "europe-north1"
}
