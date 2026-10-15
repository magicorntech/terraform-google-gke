# terraform-google-gke

Magicorn made Terraform Module for Google Cloud Provider
--
```
module "gke" {
  source         = "magicorntech/gke/google"
  version        = "0.0.1"
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

  # Node Configuration
  main_node_count     = 3
  main_min_node_count = 1
  main_max_node_count = 10
  main_machine_type   = "e2-medium"
  main_disk_type      = "pd-standard"
  main_disk_size_gb   = 30
  main_preemptible    = false

  extra_nodes_deploy   = true
  extra_node_count     = 0
  extra_min_node_count = 0
  extra_max_node_count = 25
  extra_machine_type   = "e2-medium"
  extra_disk_type      = "pd-standard"
  extra_disk_size_gb   = 30
  extra_preemptible    = true

  tmp_nodes_deploy   = false
  tmp_node_count     = 0
  tmp_min_node_count = 0
  tmp_max_node_count = 25
  tmp_machine_type   = "t2a-medium"
  tmp_disk_type      = "pd-standard"
  tmp_disk_size_gb   = 30
  tmp_preemptible    = true

  # Workload Identity (optional)
  enable_workload_identity   = false
  workload_identity_bindings = []
}
```

## Notes
1) Pair with the Magicorn `google-vpc` module. Private subnets carry GKE pod/service secondary ranges named `gke-pods` / `gke-services` (or `gke-pods-<region>` when a subnet region is set). Pass those names from `module.vpc.gke_pod_secondary_range_names` and `module.vpc.gke_svc_secondary_range_names`.
2) `managed_block` is the master CIDR used for webhook firewall rules. `additional_ips` is master authorized networks; set `[]` if unused.
3) Extra and tmp node pools are tainted `node-type=spot:NoSchedule` when preemptible is true, so only pods that tolerate it are scheduled there.
4) Project ID and region come from the Google provider. Set `region` only to override the provider region.
