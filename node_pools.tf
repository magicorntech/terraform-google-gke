##### Main Node Pool
resource "google_container_node_pool" "main" {
  name       = "${var.tenant}-${var.name}-gke-mainnode-${var.environment}"
  location   = coalesce(var.region, data.google_client_config.current.region)
  cluster    = google_container_cluster.main.name
  node_count = var.main_node_count

  # Autoscaling configuration with total node counts across all zones
  autoscaling {
    total_min_node_count = var.main_min_node_count
    total_max_node_count = var.main_max_node_count
  }

  # Management configuration
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Node configuration
  node_config {
    preemptible  = var.main_preemptible
    machine_type = var.main_machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.node.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Disk configuration
    disk_size_gb = var.main_disk_size_gb
    disk_type    = var.main_disk_type

    # Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Labels
    labels = merge({
      name         = "${var.tenant}-${var.name}-${var.cluster_name}-gke-mainnode-${var.environment}"
      tenant       = var.tenant
      project      = var.name
      cluster_name = var.cluster_name
      environment  = var.environment
      maintainer   = "magicorn"
      terraform    = "yes"
      node-type    = "main"
    }, var.main_preemptible ? { spot = "true" } : {})

    # Taints for main nodes (conditional spot taint)
    dynamic "taint" {
      for_each = var.main_preemptible ? [1] : []
      content {
        key    = "node-type"
        value  = "spot"
        effect = "NO_SCHEDULE"
      }
    }

    tags = ["gke-node", "${var.tenant}-${var.name}-gke-node"]
  }

  # Lifecycle
  lifecycle {
    ignore_changes = [
      node_count,
      initial_node_count
    ]
  }

  depends_on = [
    google_service_account.node,
    google_project_iam_member.node
  ]
}

##### Extra Node Pool (Spot/Preemptible)
resource "google_container_node_pool" "extra" {
  count      = var.extra_nodes_deploy ? 1 : 0
  name       = "${var.tenant}-${var.name}-gke-extranode-${var.environment}"
  location   = coalesce(var.region, data.google_client_config.current.region)
  cluster    = google_container_cluster.main.name
  node_count = var.extra_node_count

  # Autoscaling configuration with total node counts across all zones
  autoscaling {
    total_min_node_count = var.extra_min_node_count
    total_max_node_count = var.extra_max_node_count
  }

  # Management configuration
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Node configuration
  node_config {
    preemptible  = var.extra_preemptible
    machine_type = var.extra_machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.node.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Disk configuration
    disk_size_gb = var.extra_disk_size_gb
    disk_type    = var.extra_disk_type

    # Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Labels
    labels = merge({
      name         = "${var.tenant}-${var.name}-${var.cluster_name}-gke-extranode-${var.environment}"
      tenant       = var.tenant
      project      = var.name
      cluster_name = var.cluster_name
      environment  = var.environment
      maintainer   = "magicorn"
      terraform    = "yes"
      node-type    = "extra"
    }, var.extra_preemptible ? { spot = "true" } : {})

    # Taints for extra nodes (conditional spot taint)
    dynamic "taint" {
      for_each = var.extra_preemptible ? [1] : []
      content {
        key    = "node-type"
        value  = "spot"
        effect = "NO_SCHEDULE"
      }
    }

    tags = ["gke-node", "${var.tenant}-${var.name}-gke-node", "spot"]
  }

  # Lifecycle
  lifecycle {
    ignore_changes = [
      node_count,
      initial_node_count
    ]
  }

  depends_on = [
    google_service_account.node,
    google_project_iam_member.node
  ]
}

##### Temporary Node Pool
resource "google_container_node_pool" "tmp" {
  count      = var.tmp_nodes_deploy ? 1 : 0
  name       = "${var.tenant}-${var.name}-gke-tmpnode-${var.environment}"
  location   = coalesce(var.region, data.google_client_config.current.region)
  cluster    = google_container_cluster.main.name
  node_count = var.tmp_node_count

  # Autoscaling configuration with total node counts across all zones
  autoscaling {
    total_min_node_count = var.tmp_min_node_count
    total_max_node_count = var.tmp_max_node_count
  }

  # Management configuration
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Node configuration
  node_config {
    preemptible  = var.tmp_preemptible
    machine_type = var.tmp_machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.node.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Disk configuration
    disk_size_gb = var.tmp_disk_size_gb
    disk_type    = var.tmp_disk_type

    # Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Labels
    labels = merge({
      name        = "${var.tenant}-${var.name}-${var.cluster_name}-gke-tmpnode-${var.environment}"
      tenant      = var.tenant
      project     = var.name
      environment = var.environment
      maintainer  = "magicorn"
      terraform   = "yes"
      node-type   = "temporary"
    }, var.tmp_preemptible ? { spot = "true" } : {})

    # Taints for temporary nodes (conditional spot taint)
    dynamic "taint" {
      for_each = var.tmp_preemptible ? [1] : []
      content {
        key    = "node-type"
        value  = "spot"
        effect = "NO_SCHEDULE"
      }
    }

    tags = ["gke-node", "${var.tenant}-${var.name}-gke-node", "temporary"]
  }

  # Lifecycle
  lifecycle {
    ignore_changes = [
      node_count,
      initial_node_count
    ]
  }

  depends_on = [
    google_service_account.node,
    google_project_iam_member.node
  ]
}
