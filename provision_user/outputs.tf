output "user_id" {
  value = one([for user in ssh_resource.user : trimspace(user.result)])
}
