output "server_ip" {
  value = hcloud_server.this.ipv4_address
}

output "server_ipv6" {
  value = hcloud_server.this.ipv6_address
}

output "server_host_keys" {
  value = { for algorithm, host_key in tls_private_key.host_key : algorithm => host_key.public_key_openssh }
}