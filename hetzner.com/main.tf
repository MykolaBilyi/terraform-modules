locals {
  # Make kebab-case from project name
  name_prefix = replace(lower(trimspace(var.name)), "/[^0-9a-z-]+/", "-")
}

resource "hcloud_server" "this" {
  name        = "${local.name_prefix}-server"
  image       = var.hetzner_vps_image
  server_type = var.hetzner_vps_type
  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.primary_ip.id
    ipv6_enabled = true
  }
  datacenter = var.hetzner_datacenter
  labels     = var.hetzner_labels
  ssh_keys   = [hcloud_ssh_key.default.id]
  user_data  = var.init_script
}

resource "hcloud_primary_ip" "primary_ip" {
  name          = "${local.name_prefix}-primary-ip"
  datacenter    = var.hetzner_datacenter
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = false
  labels        = var.hetzner_labels
}

resource "hcloud_ssh_key" "default" {
  name       = "${local.name_prefix}-public-key"
  public_key = var.public_key
  labels     = var.hetzner_labels
}

resource "hcloud_rdns" "domain_name" {
  count = var.domain_name != "" ? 1 : 0

  server_id  = hcloud_server.this.id
  ip_address = hcloud_server.this.ipv4_address
  dns_ptr    = var.domain_name
}
