locals {
  home_dir = var.user_name == "root" ? "/root" : "/home/${var.user_name}"
}

resource "ssh_resource" "add_user" {
  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key

  when = "create"

  commands = [
    "id -u ${var.user_name} >/dev/null  2>&1 || sudo useradd -s /bin/bash ${var.user_name}",
    "id -u ${var.user_name}",
  ]
}

resource "ssh_resource" "delete_user" {
  count = var.on_destroy == "delete" ? 1 : 0

  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key

  when = "destroy"

  commands = [
    "sudo deluser --remove-home ${var.user_name}",
  ]
}

resource "ssh_resource" "keys" {
  count = length(var.public_keys) > 0 ? 1 : 0

  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key

  when = "create"

  file {
    content     = <<EOT
%{ for key in var.public_keys ~}
${key}
%{ endfor ~}
EOT
    destination = "/tmp/public_keys.pub"
    permissions = "0600"
  }

  commands = [
    "sudo mkdir -p ${local.home_dir}/.ssh ",
    "sudo chown ${var.user_name}:${var.user_name} ${local.home_dir}/.ssh ",
    "sudo chmod 0700 ${local.home_dir}/.ssh ",
    "sudo mv /tmp/public_keys.pub ${local.home_dir}/.ssh/authorized_keys",
    "sudo chown ${var.user_name}:${var.user_name} ${local.home_dir}/.ssh/authorized_keys",
  ]
}

resource "ssh_resource" "add_user_groups" {
  count = length(var.groups) > 0 ? 1 : 0

  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key

  when = "create"

  file {
    content     = "${var.user_name} ALL=(ALL) NOPASSWD: ALL\n"
    destination = "/tmp/sudoers_${var.user_name}"
    permissions = "0600"
  }

  commands = concat(
    [
      for group in var.groups : (
        group == "sudo" ?
        "sudo cp /tmp/sudoers_${var.user_name} /etc/sudoers.d/${var.user_name}" :
        "sudo usermod -aG ${group} ${var.user_name}"
      )
      ], [
      "rm /tmp/sudoers_${var.user_name}",
      "sudo chown root:root /etc/sudoers.d/${var.user_name} || true",
    ]
  )
}

resource "ssh_resource" "remove_sudoers" {
  count = var.on_destroy == "delete" && contains(var.groups, "sudo") ? 1 : 0

  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key

  when = "destroy"

  commands = [
    "sudo rm -f /etc/sudoers.d/${var.user_name}",
  ]
}