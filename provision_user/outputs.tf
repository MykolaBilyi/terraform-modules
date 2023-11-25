output "user_id" {
  value = trimspace(ssh_resource.users.result)
  description = "User ID"
}

output "user_name" {
  value = var.user_name
  description = "User name"
}
