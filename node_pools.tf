resource "google_container_node_pool" "pools" {
  for_each   = local.node_pools
  name       = "${var.tenant}-${var.name}-gke-${each.key}node-${var.environment}"
  location   = coalesce(var.region, data.google_client_config.current.region)
  cluster    = google_container_cluster.main.name
  node_count = each.value.scaling_config.desired

  autoscaling {
    total_min_node_count = each.value.scaling_config.min
    total_max_node_count = each.value.scaling_config.max
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = each.value.preemptible
    machine_type = each.value.machine_type

    service_account = google_service_account.node.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    disk_size_gb = lookup(each.value, "disk_size_gb", 30)
    disk_type    = lookup(each.value, "disk_type", "pd-standard")

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = merge(
      {
        name        = "${var.tenant}-${var.name}-${var.cluster_name}-gke-${each.key}node-${var.environment}"
        tenant      = var.tenant
        project     = var.name
        environment = var.environment
        maintainer  = "magicorn"
        terraform   = "yes"
        node-type   = lookup(each.value, "node_type", each.key)
      },
      lookup(each.value, "include_cluster_label", true) ? { cluster_name = var.cluster_name } : {},
      each.value.preemptible ? { spot = "true" } : {}
    )

    dynamic "taint" {
      for_each = each.value.taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    tags = concat(
      ["gke-node", "${var.tenant}-${var.name}-gke-node"],
      each.value.tags
    )
  }

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
