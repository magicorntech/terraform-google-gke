##### Create GKE Cluster
resource "google_container_cluster" "main" {
  name     = "${var.tenant}-${var.name}-gke-${var.cluster_name}-${var.environment}"
  location = coalesce(var.region, data.google_client_config.current.region)

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  # Network configuration
  network    = var.vpc_id
  subnetwork = var.subnet_id

  # IP allocation policy for VPC-native networking with secondary IP ranges
  ip_allocation_policy {
    stack_type                    = "IPV4"
    cluster_secondary_range_name  = coalesce(var.gke_pod_secondary_range_name, var.region != null ? "gke-pods-${var.region}" : "gke-pods")
    services_secondary_range_name = coalesce(var.gke_svc_secondary_range_name, var.region != null ? "gke-services-${var.region}" : "gke-services")
  }

  # Master authorized networks
  dynamic "master_authorized_networks_config" {
    for_each = length(var.additional_ips) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.additional_ips
        content {
          cidr_block   = cidr_blocks.value
          display_name = "Additional IP ${cidr_blocks.key + 1}"
        }
      }
    }
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${data.google_project.current.project_id}.svc.id.goog"
  }

  # Network policy
  network_policy {
    enabled = var.network_policy_enabled
  }

  # Addons
  addons_config {
    http_load_balancing {
      disabled = !var.http_load_balancing
    }
    horizontal_pod_autoscaling {
      disabled = !var.horizontal_pod_autoscaling
    }
    network_policy_config {
      disabled = !var.network_policy_enabled
    }
    dns_cache_config {
      enabled = var.dns_cache_enabled
    }
    gcp_filestore_csi_driver_config {
      enabled = true
    }
  }

  # DNS configuration - CoreDNS with VPC scope for cross-VPC resolution
  dns_config {
    cluster_dns        = "CLOUD_DNS"
    cluster_dns_scope  = "VPC_SCOPE"
    cluster_dns_domain = var.region != null ? "${var.environment}.${var.cluster_name}.${var.name}.${var.tenant}.cluster.local" : "${var.environment}.${var.name}.${var.tenant}.cluster.local"
  }

  # Control plane endpoints configuration with DNS endpoint
  control_plane_endpoints_config {
    dns_endpoint_config {
      allow_external_traffic = false
    }
    ip_endpoints_config {
      enabled = true
    }
  }

  # Private cluster configuration - private control plane, nodes toggleable via var.enable_private_nodes (PSC-based)
  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes # Nodes only get internal IPs when true; outbound access via Cloud NAT
    enable_private_endpoint = true                     # Control plane is private only

    master_global_access_config {
      enabled = true
    }
  }

  # Release channel
  release_channel {
    channel = var.release_channel
  }

  # Logging and monitoring
  logging_service    = var.logging_enabled ? var.logging_service : "none"
  monitoring_service = var.monitoring_enabled ? var.monitoring_service : "none"

  # Secret Manager configuration
  dynamic "secret_manager_config" {
    for_each = var.secret_manager_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  # Disable deletion protection to allow cluster recreation
  deletion_protection = false

  # # Lifecycle
  # lifecycle {
  #   prevent_destroy = true
  # }

  # Depends on service account
  depends_on = [
    google_service_account.cluster,
    google_project_iam_member.cluster
  ]

  # Labels
  resource_labels = {
    name         = "${var.tenant}-${var.name}-gke-${var.cluster_name}-${var.environment}"
    tenant       = var.tenant
    project      = var.name
    cluster_name = var.cluster_name
    environment  = var.environment
    maintainer   = "magicorn"
    terraform    = "yes"
  }
}
