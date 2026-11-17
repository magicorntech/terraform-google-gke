# terraform-google-gke

Magicorn made Terraform Module for Google Cloud Provider
--
```
module "gke" {
  source         = "magicorntech/gke/google"
  version        = "0.1.0"
  tenant         = var.tenant
  name           = var.name
  environment    = var.environment
  vpc_id                       = module.vpc.vpc_self_link
  subnet_id                    = module.vpc.pvt_subnet_ids[0]
  gke_pod_secondary_range_name = module.vpc.gke_pod_secondary_range_names[0]
  gke_svc_secondary_range_name = module.vpc.gke_svc_secondary_range_names[0]
  managed_block                = "172.16.0.0/28"
  additional_ips               = ["10.20.8.2/32"] # should be set empty []

  # Cluster Configuration
  cluster_name               = "cluster"
  release_channel            = "STABLE"
  enable_private_nodes       = true
  network_policy_enabled     = true
  http_load_balancing        = true
  horizontal_pod_autoscaling = true
  dns_cache_enabled          = true
  logging_enabled            = true
  monitoring_enabled         = true
  secret_manager_enabled     = true

  # Node Configuration (set null to use legacy inputs, {} to create no pools)
  node_pools = {
    main = {
      machine_type = "e2-medium"
      disk_type    = "pd-standard"
      disk_size_gb = 30
      preemptible  = false
      scaling_config = {
        desired = 3
        min     = 1
        max     = 10
      }
    }
    extra = {
      machine_type = "e2-medium"
      disk_type    = "pd-standard"
      disk_size_gb = 30
      preemptible  = true
      scaling_config = {
        desired = 0
        min     = 0
        max     = 25
      }
      taints = [{
        key    = "node-type"
        value  = "spot"
        effect = "NO_SCHEDULE"
      }]
    }
    tmp = {
      machine_type = "t2a-medium"
      disk_type    = "pd-standard"
      disk_size_gb = 30
      preemptible  = true
      scaling_config = {
        desired = 0
        min     = 0
        max     = 25
      }
      taints = [{
        key    = "node-type"
        value  = "spot"
        effect = "NO_SCHEDULE"
      }]
    }
  }

  # Workload Identity (optional)
  enable_workload_identity   = false
  workload_identity_bindings = []
}
```

## Notes
1) Pair with the Magicorn `google-vpc` module. Private subnets carry GKE pod/service secondary ranges named `gke-pods` / `gke-services` (or `gke-pods-<region>` when a subnet region is set). Pass those names from `module.vpc.gke_pod_secondary_range_names` and `module.vpc.gke_svc_secondary_range_names`.
2) `managed_block` is the master CIDR used for webhook firewall rules. `additional_ips` is master authorized networks; set `[]` if unused.
3) Each `node_pools` map key becomes one node pool (`gke-<key>node`). Each pool has its own `scaling_config` (`desired`, `min`, `max`) and optional `taints` list using the same `{ key, value, effect }` shape and effect values as EKS.
4) Legacy `main_*`, `extra_*`, and `tmp_*` inputs remain supported when `node_pools` is omitted/null. Legacy extra/tmp pools retain their automatic spot taint; map-based pools use only explicitly configured `taints`.
5) Project ID and region come from the Google provider. Set `region` only to override the provider region.
