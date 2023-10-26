output "user_id" {
  value = trimspace(ssh_resource.add_user.result)
}
