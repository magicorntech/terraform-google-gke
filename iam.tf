##### Create GKE Service Account
resource "google_service_account" "cluster" {
  account_id   = "${var.tenant}-${random_id.cluster.hex}-${var.environment}"
  display_name = "${var.tenant}-${var.name}-gke-cluster-sa-${random_id.cluster.hex}-${var.environment}"
  description  = "Service account for GKE cluster managed by Magicorn"
}

##### Cluster IAM bindings
resource "google_project_iam_member" "cluster" {
  for_each = toset([
    "roles/container.clusterAdmin",
    "roles/compute.instanceAdmin.v1",
    "roles/iam.serviceAccountUser"
  ])
  project = data.google_project.current.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cluster.email}"
}

##### Create Node Pool Service Account
resource "google_service_account" "node" {
  account_id   = "${var.tenant}-${random_id.node.hex}-${var.environment}"
  display_name = "${var.tenant}-${var.name}-gke-node-sa-${random_id.node.hex}-${var.environment}"
  description  = "Service account for GKE node pools managed by Magicorn"
}

##### Node Pool IAM bindings
resource "google_project_iam_member" "node" {
  for_each = toset([
    "roles/container.nodeServiceAccount",
    "roles/compute.instanceAdmin.v1",
    "roles/storage.objectViewer",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer"
  ])
  project = data.google_project.current.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.node.email}"
}

##### Workload Identity binding - single resource for all namespace/service account combinations
resource "google_service_account_iam_binding" "assume_role" {
  count = var.enable_workload_identity ? 1 : 0

  service_account_id = google_service_account.node.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    for binding in distinct([for b in var.workload_identity_bindings : "${b.namespace}/${b.service_account}"]) :
    "serviceAccount:${data.google_project.current.project_id}.svc.id.goog[${split("/", binding)[0]}/${split("/", binding)[1]}]"
  ]
}

##### Additional role bindings for multiple namespace/service account combinations
resource "google_project_iam_member" "additional_role" {
  for_each = var.enable_workload_identity ? {
    for binding in var.workload_identity_bindings : "${binding.namespace}/${binding.service_account}/${binding.role}" => binding
  } : {}

  project = data.google_project.current.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.node.email}"
}
