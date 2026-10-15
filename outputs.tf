output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.main.name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.main.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = google_container_cluster.main.master_auth.0.cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "GKE cluster location"
  value       = google_container_cluster.main.location
}

output "cluster_id" {
  description = "GKE cluster ID"
  value       = google_container_cluster.main.id
}

output "cluster_self_link" {
  description = "GKE cluster self link"
  value       = google_container_cluster.main.self_link
}

output "cluster_service_account_email" {
  description = "Email of the cluster service account"
  value       = google_service_account.cluster.email
}

output "node_service_account_email" {
  description = "Email of the node service account"
  value       = google_service_account.node.email
}

output "main_node_pool_name" {
  description = "Name of the main node pool"
  value       = google_container_node_pool.main.name
}

output "extra_node_pool_name" {
  description = "Name of the extra node pool"
  value       = var.extra_nodes_deploy ? google_container_node_pool.extra[0].name : null
}

output "tmp_node_pool_name" {
  description = "Name of the temporary node pool"
  value       = var.tmp_nodes_deploy ? google_container_node_pool.tmp[0].name : null
}

output "workload_identity_pool" {
  description = "Workload Identity pool"
  value       = "${data.google_project.current.project_id}.svc.id.goog"
}

output "project_id" {
  description = "GCP Project ID"
  value       = data.google_project.current.project_id
}

output "region" {
  description = "GCP Region"
  value       = data.google_client_config.current.region
}

output "private_endpoint" {
  description = "The private IP address of the master"
  value       = google_container_cluster.main.private_cluster_config[0].private_endpoint
}

output "private_endpoint_subnetwork" {
  description = "The subnetwork used for the private endpoint"
  value       = google_container_cluster.main.private_cluster_config[0].private_endpoint_subnetwork
}

output "peering_name" {
  description = "The name of the VPC Network Peering connection"
  value       = google_container_cluster.main.private_cluster_config[0].peering_name
}

##### Private Cluster Outputs
output "gke_api_private_endpoint" {
  description = "Private endpoint of the GKE API server"
  value       = google_container_cluster.main.private_cluster_config[0].private_endpoint
}

##### GKE Cluster Information
output "gke_cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.main.name
}

output "gke_cluster_location" {
  description = "GKE cluster location"
  value       = google_container_cluster.main.location
}
