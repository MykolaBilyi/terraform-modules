locals {
  # scheme:[//[user[:password]@]host[:port]]path[?query][#fragment]
  uri       = regex("^(?:(?P<scheme>[^:\\/?#]+):)?(?://(?P<authority>[^\\/?#]*))?(?P<path>[^?#]*)(?:\\?(?P<query>[^#]*))?(?:#(?P<fragment>.*))?$", var.string)
  authority = regex("^(?:(?P<user>[^@\\/:]+)(?::(?P<password>[^@\\/]*))?@)?(?:(?:(?P<host>\\S*):(?P<port>[0-9]+))|(?P<host_no_port>\\S*))$", local.uri.authority != null ? local.uri.authority : "")
}

output "scheme" {
  value       = nonsensitive(local.uri.scheme)
  sensitive   = false
  description = "Connection scheme/protocol/type"
}

output "host" {
  value       = local.uri.authority != null ? nonsensitive(coalesce(local.authority.host, local.authority.host_no_port)) : ""
  sensitive   = false
  description = "Connection host"
}

output "port" {
  value       = local.authority.port != null ? nonsensitive(tonumber(local.authority.port)) : var.default_port
  sensitive   = false
  description = "Connection port"
}

output "user" {
  value       = local.authority.user != null ? nonsensitive(local.authority.user) : var.default_user
  sensitive   = false
  description = "Connection user"
}

output "password" {
  value       = local.authority.password
  sensitive   = true
  description = "Connection password"
}

output "authority" {
  value       = local.authority.password == null ? local.uri.authority : nonsensitive(local.uri.authority)
  description = "Connection authority"
}

output "path" {
  value       = nonsensitive(local.uri.path)
  sensitive   = false
  description = "Connection path"
}

output "query" {
  value       = nonsensitive(local.uri.query)
  sensitive   = false
  description = "Connection query"
}

output "fragment" {
  value       = nonsensitive(local.uri.fragment)
  sensitive   = false
  description = "Connection fragment"
}

output "agent" {
  value       = var.agent
  description = "Force use of ssh-agent"
}

output "private_key" {
  value       = var.private_key
  sensitive   = true
  description = "Private key to use for authentication"
}
