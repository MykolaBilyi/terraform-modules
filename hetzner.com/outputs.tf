output "server_ip" {
  value = hcloud_server.this.ipv4_address
}

output "server_ipv6" {
  value = hcloud_server.this.ipv6_address
}
