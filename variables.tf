variable "tenant" {
  description = "Tenant name"
  type        = string
}

variable "name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# Note: project_id and location are now obtained from data sources in data.tf

variable "region" {
  description = "Region for GKE cluster (defaults to provider region if not specified)"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC network name or self_link"
  type        = string
}

variable "subnet_id" {
  description = "Subnet name or self_link for GKE cluster and nodes"
  type        = string
}

variable "gke_pod_secondary_range_name" {
  description = "Secondary IP range name for GKE pods. Defaults to google-vpc naming (gke-pods or gke-pods-<region>)."
  type        = string
  default     = null
}

variable "gke_svc_secondary_range_name" {
  description = "Secondary IP range name for GKE services. Defaults to google-vpc naming (gke-services or gke-services-<region>)."
  type        = string
  default     = null
}

variable "additional_ips" {
  description = "Additional IP ranges that can access the master"
  type        = list(string)
  default     = []
}

variable "managed_block" {
  description = "CIDR block for the master network"
  type        = string
  default     = "172.16.0.0/28"
}

variable "enable_private_nodes" {
  description = "If true, nodes only get internal IPs (outbound access via Cloud NAT). If false, nodes also get public IPs."
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "network_policy_enabled" {
  description = "Enable network policy"
  type        = bool
  default     = true
}

variable "http_load_balancing" {
  description = "Enable HTTP load balancing addon"
  type        = bool
  default     = true
}

variable "horizontal_pod_autoscaling" {
  description = "Enable horizontal pod autoscaling addon"
  type        = bool
  default     = true
}

variable "dns_cache_enabled" {
  description = "Enable DNS cache"
  type        = bool
  default     = true
}

variable "release_channel" {
  description = "GKE release channel"
  type        = string
  default     = "STABLE"
}

variable "logging_service" {
  description = "Logging service"
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

variable "monitoring_service" {
  description = "Monitoring service"
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
}

variable "logging_enabled" {
  description = "Enable logging service"
  type        = bool
  default     = true
}

variable "monitoring_enabled" {
  description = "Enable monitoring service"
  type        = bool
  default     = true
}

variable "secret_manager_enabled" {
  description = "Enable Secret Manager integration"
  type        = bool
  default     = false
}

# Node pool variables
variable "main_node_count" {
  description = "Initial total number of nodes in the main node pool across all zones"
  type        = number
  default     = 3
}

variable "main_min_node_count" {
  description = "Minimum total number of nodes in the main node pool across all zones"
  type        = number
  default     = 1
}

variable "main_max_node_count" {
  description = "Maximum total number of nodes in the main node pool across all zones"
  type        = number
  default     = 10
}

variable "main_machine_type" {
  description = "Machine type for main node pool"
  type        = string
  default     = "e2-medium"
}

variable "main_disk_type" {
  description = "Disk type for main node pool"
  type        = string
  default     = "pd-standard"
}

variable "main_disk_size_gb" {
  description = "Disk size in GB for main node pool"
  type        = number
  default     = 30
}

variable "main_preemptible" {
  description = "Use preemptible instances for main node pool"
  type        = bool
  default     = false
}

variable "extra_nodes_deploy" {
  description = "Deploy extra node pool"
  type        = bool
  default     = false
}

variable "extra_node_count" {
  description = "Initial total number of nodes in the extra node pool across all zones"
  type        = number
  default     = 0
}

variable "extra_min_node_count" {
  description = "Minimum total number of nodes in the extra node pool across all zones"
  type        = number
  default     = 0
}

variable "extra_max_node_count" {
  description = "Maximum total number of nodes in the extra node pool across all zones"
  type        = number
  default     = 25
}

variable "extra_machine_type" {
  description = "Machine type for extra node pool"
  type        = string
  default     = "e2-medium"
}

variable "extra_disk_type" {
  description = "Disk type for extra node pool"
  type        = string
  default     = "pd-standard"
}

variable "extra_disk_size_gb" {
  description = "Disk size in GB for extra node pool"
  type        = number
  default     = 30
}

variable "extra_preemptible" {
  description = "Use preemptible instances for extra node pool"
  type        = bool
  default     = true
}

variable "tmp_nodes_deploy" {
  description = "Deploy temporary node pool"
  type        = bool
  default     = false
}

variable "tmp_node_count" {
  description = "Initial total number of nodes in the temporary node pool across all zones"
  type        = number
  default     = 0
}

variable "tmp_min_node_count" {
  description = "Minimum total number of nodes in the temporary node pool across all zones"
  type        = number
  default     = 0
}

variable "tmp_max_node_count" {
  description = "Maximum total number of nodes in the temporary node pool across all zones"
  type        = number
  default     = 25
}

variable "tmp_machine_type" {
  description = "Machine type for temporary node pool"
  type        = string
  default     = "t2a-medium"
}

variable "tmp_disk_type" {
  description = "Disk type for temporary node pool"
  type        = string
  default     = "pd-standard"
}

variable "tmp_disk_size_gb" {
  description = "Disk size in GB for temporary node pool"
  type        = number
  default     = 30
}

variable "tmp_preemptible" {
  description = "Use preemptible instances for temporary node pool"
  type        = bool
  default     = true
}

# Workload Identity variables
variable "enable_workload_identity" {
  description = "Enable Workload Identity"
  type        = bool
  default     = false
}

variable "workload_identity_bindings" {
  description = "List of Workload Identity bindings (namespace/service_account pairs)"
  type = list(object({
    namespace       = string
    service_account = string
    role            = string
  }))
  default = []
}

# Custom firewall rules
variable "custom_firewall_rules" {
  description = "Map of custom firewall rules to create for the GKE cluster"
  type = map(object({
    description   = optional(string, "Custom firewall rule")
    direction     = optional(string, "INGRESS")
    priority      = optional(number, 1000)
    source_ranges = optional(list(string), [])
    source_tags   = optional(list(string), [])
    target_tags   = optional(list(string), []) # If empty, defaults to GKE node tags
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    disabled = optional(bool, false)
  }))
  default = {}

  # Example usage:
  # custom_firewall_rules = {
  #   agones = {
  #     description   = "Allow Agones game server traffic"
  #     source_ranges = ["0.0.0.0/0"]
  #     allow = [
  #       { protocol = "udp", ports = ["15000"] },
  #       { protocol = "udp", ports = ["7000-8000"] }
  #     ]
  #   }
  #   custom-tcp = {
  #     description   = "Allow custom TCP traffic"
  #     source_ranges = ["10.0.0.0/8"]
  #     allow = [
  #       { protocol = "tcp", ports = ["8080", "9090"] }
  #     ]
  #   }
  # }
}
