##### Firewall rules for GKE cluster
resource "google_compute_firewall" "gke_master_webhook" {
  name    = "${var.tenant}-${var.name}-${var.cluster_name}-gke-master-webhook-${var.environment}"
  network = var.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["8443", "9443", "15017"]
  }

  # Allow from GKE master CIDR block
  source_ranges = [var.managed_block]
  target_tags   = ["gke-node", "${var.tenant}-${var.name}-gke-node"]

  description = "Allow master to access webhook on nodes"
}

##### Allow nodes to communicate with each other
resource "google_compute_firewall" "gke_nodes_internal" {
  name    = "${var.tenant}-${var.name}-${var.cluster_name}-gke-nodes-internal-${var.environment}"
  network = var.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_tags = ["gke-node", "${var.tenant}-${var.name}-gke-node"]
  target_tags = ["gke-node", "${var.tenant}-${var.name}-gke-node"]

  description = "Allow nodes to communicate with each other"
}

##### Allow ingress from load balancers
resource "google_compute_firewall" "gke_ingress" {
  name    = "${var.tenant}-${var.name}-${var.cluster_name}-gke-ingress-${var.environment}"
  network = var.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = [
    "130.211.0.0/22",  # Google Cloud Load Balancer ranges
    "35.191.0.0/16",   # Google Cloud Load Balancer ranges
    "209.85.152.0/22", # Google Cloud Load Balancer ranges
    "209.85.204.0/22"  # Google Cloud Load Balancer ranges
  ]
  target_tags = ["gke-node", "${var.tenant}-${var.name}-gke-node"]

  description = "Allow ingress from Google Cloud Load Balancers"
}

# SSH access removed - GKE nodes should be managed through kubectl and not direct SSH

##### Allow health checks
resource "google_compute_firewall" "gke_health_checks" {
  name    = "${var.tenant}-${var.name}-${var.cluster_name}-gke-health-checks-${var.environment}"
  network = var.vpc_id

  allow {
    protocol = "tcp"
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]
  target_tags = ["gke-node", "${var.tenant}-${var.name}-gke-node"]

  description = "Allow health checks from Google Cloud Load Balancers"
}

##### Custom firewall rules (configurable via variable)
resource "google_compute_firewall" "custom" {
  for_each = var.custom_firewall_rules

  name     = "${var.tenant}-${var.name}-${var.cluster_name}-gke-${each.key}-${var.environment}"
  network  = var.vpc_id
  disabled = each.value.disabled

  direction = each.value.direction
  priority  = each.value.priority

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = length(allow.value.ports) > 0 ? allow.value.ports : null
    }
  }

  dynamic "deny" {
    for_each = each.value.deny
    content {
      protocol = deny.value.protocol
      ports    = length(deny.value.ports) > 0 ? deny.value.ports : null
    }
  }

  source_ranges = length(each.value.source_ranges) > 0 ? each.value.source_ranges : null
  source_tags   = length(each.value.source_tags) > 0 ? each.value.source_tags : null
  target_tags   = length(each.value.target_tags) > 0 ? each.value.target_tags : ["gke-node", "${var.tenant}-${var.name}-gke-node"]

  description = each.value.description
}
