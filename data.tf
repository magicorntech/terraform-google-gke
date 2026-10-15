data "google_client_config" "current" {}
data "google_project" "current" {}
data "google_compute_zones" "available" {}

resource "random_id" "cluster" {
  byte_length = 4
}

resource "random_id" "node" {
  byte_length = 4
}
