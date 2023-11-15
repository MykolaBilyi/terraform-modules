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
    ipv6_enabled = true
  }
  datacenter = var.hetzner_datacenter
  labels     = var.hetzner_labels
  ssh_keys   = [hcloud_ssh_key.default.id]
  user_data  = var.init_script

  provisioner "file" {
    connection { host = self.ipv4_address }
    content     = tls_private_key.host_key["RSA"].public_key_openssh
    destination = "/etc/ssh/ssh_host_rsa_key.pub"
  }
  provisioner "file" {
    connection { host = self.ipv4_address }
    content     = tls_private_key.host_key["RSA"].private_key_openssh
    destination = "/etc/ssh/ssh_host_rsa_key"
  }

  provisioner "file" {
    connection { host = self.ipv4_address }
    content     = tls_private_key.host_key["ECDSA"].public_key_openssh
    destination = "/etc/ssh/ssh_host_ecdsa_key.pub"
  }
  provisioner "file" {
    connection { host = self.ipv4_address }
    content     = tls_private_key.host_key["ECDSA"].private_key_openssh
    destination = "/etc/ssh/ssh_host_ecdsa_key"
  }

  provisioner "file" {
    connection { host = self.ipv4_address }
    content     = tls_private_key.host_key["ED25519"].public_key_openssh
    destination = "/etc/ssh/ssh_host_ed25519_key.pub"
  }
  provisioner "file" {
    connection { host = self.ipv4_address }
    content     = tls_private_key.host_key["ED25519"].private_key_openssh
    destination = "/etc/ssh/ssh_host_ed25519_key"
  }
  
  provisioner "remote-exec" {
    # Remove old host keys
    connection { host = self.ipv4_address }
    inline = [
      "rm -r `ls /etc/ssh/ssh_host_*| grep -v \"/ssh_host_rsa_key\\(.pub\\)\\?\\$\\|/ssh_host_ecdsa_key\\(.pub\\)\\?\\$\\|/ssh_host_ed25519_key\\(.pub\\)\\?\\$\"`",
      "chmod 0600 /etc/ssh/ssh_host_*_key",
      "chmod 0644 /etc/ssh/ssh_host_*_key.pub",
    ]
  }
}

resource "tls_private_key" "host_key" {
  for_each =  toset(["RSA", "ECDSA", "ED25519"])
  algorithm = each.key
  rsa_bits  = 4096
  ecdsa_curve = "P384"
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
