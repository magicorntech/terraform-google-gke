data "google_client_config" "current" {}
data "google_project" "current" {}
data "google_compute_zones" "available" {}

resource "random_id" "cluster" {
  byte_length = 4
}

resource "random_id" "node" {
  byte_length = 4
}

locals {
  legacy_node_pools = merge(
    {
      main = {
        machine_type = var.main_machine_type
        disk_type    = var.main_disk_type
        disk_size_gb = var.main_disk_size_gb
        preemptible  = var.main_preemptible
        scaling_config = {
          desired = var.main_node_count
          min     = var.main_min_node_count
          max     = var.main_max_node_count
        }
        node_type             = "main"
        include_cluster_label = true
        tags                  = []
        taints = var.main_preemptible ? [{
          key    = "node-type"
          value  = "spot"
          effect = "NO_SCHEDULE"
        }] : []
      }
    },
    var.extra_nodes_deploy ? {
      extra = {
        machine_type = var.extra_machine_type
        disk_type    = var.extra_disk_type
        disk_size_gb = var.extra_disk_size_gb
        preemptible  = var.extra_preemptible
        scaling_config = {
          desired = var.extra_node_count
          min     = var.extra_min_node_count
          max     = var.extra_max_node_count
        }
        node_type             = "extra"
        include_cluster_label = true
        tags                  = ["spot"]
        taints = var.extra_preemptible ? [{
          key    = "node-type"
          value  = "spot"
          effect = "NO_SCHEDULE"
        }] : []
      }
    } : {},
    var.tmp_nodes_deploy ? {
      tmp = {
        machine_type = var.tmp_machine_type
        disk_type    = var.tmp_disk_type
        disk_size_gb = var.tmp_disk_size_gb
        preemptible  = var.tmp_preemptible
        scaling_config = {
          desired = var.tmp_node_count
          min     = var.tmp_min_node_count
          max     = var.tmp_max_node_count
        }
        node_type             = "temporary"
        include_cluster_label = false
        tags                  = ["temporary"]
        taints = var.tmp_preemptible ? [{
          key    = "node-type"
          value  = "spot"
          effect = "NO_SCHEDULE"
        }] : []
      }
    } : {}
  )

  node_pools = var.node_pools == null ? local.legacy_node_pools : {
    for name, pool in var.node_pools : name => {
      machine_type = coalesce(try(pool.machine_type, null), "e2-medium")
      disk_type    = coalesce(try(pool.disk_type, null), "pd-standard")
      disk_size_gb = coalesce(try(pool.disk_size_gb, null), 30)
      preemptible  = coalesce(try(pool.preemptible, null), false)
      scaling_config = {
        desired = try(pool.scaling_config == null ? 1 : lookup(pool.scaling_config, "desired", 1), 1)
        min     = try(pool.scaling_config == null ? 0 : lookup(pool.scaling_config, "min", 0), 0)
        max     = try(pool.scaling_config == null ? 1 : lookup(pool.scaling_config, "max", 1), 1)
      }
      node_type             = coalesce(try(pool.node_type, null), name)
      include_cluster_label = coalesce(try(pool.include_cluster_label, null), true)
      tags                  = try(pool.tags == null ? [] : pool.tags, [])
      taints                = try(pool.taints == null ? [] : pool.taints, [])
    }
  }
}
