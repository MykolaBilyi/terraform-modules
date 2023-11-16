locals {
  users                    = toset([var.user_name])
  users_home_dir           = { for user in local.users : user => user == "root" ? "/root" : "/home/${user}" }
  users_non_root           = toset([for user in local.users : user if user != "root"])
  users_to_cleanup         = toset([for user in local.users_non_root : user if var.on_destroy == "delete"])
  users_sudoers            = toset([for user in local.users_non_root : user if contains(var.groups, "sudo")])
  users_sudoers_to_cleanup = toset([for user in local.users_sudoers : user if var.on_destroy == "delete"])
  groups                   = toset([for group in var.groups : group if group != "sudo"])
  user_groups = [
    for pair in setproduct(local.users_non_root, local.groups) : {
      user  = pair[0]
      group = pair[1]
    }
  ]
  keys = { for key in var.public_keys : trimspace(element(concat(split(" ", key), ["key#${md5(key)}"]), 2)) => "${trimspace(key)}\n" }
  user_keys = [
    for pair in setproduct(local.users, keys(local.keys)) : {
      user     = pair[0]
      home_dir = local.users_home_dir[pair[0]]
      name     = pair[1]
      file     = "${local.users_home_dir[pair[0]]}/.ssh/authorized_keys.d/${pair[1]}"
      key      = local.keys[pair[1]]
    }
  ]
  user_keys_to_cleanup = toset([for key in local.user_keys : key if var.on_destroy == "delete_keys"])
}

resource "ssh_resource" "user" {
  for_each = local.users_home_dir

  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key
  agent       = var.connection.agent

  when = "create"

  commands = [
    "id -u ${each.key} >/dev/null  2>&1 || sudo useradd -s /bin/bash ${each.key}",
    "sudo mkdir -p ${each.value} && sudo chown ${each.key}:${each.key} ${each.value}",
    "id -u ${each.key}",
  ]
}

resource "ssh_resource" "user_key" {
  for_each = {
    for key in local.user_keys : "${key.user}.${key.name}" => key
  }

  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key
  agent       = var.connection.agent

  when = "create"

  pre_commands = [
    "sudo mkdir -p ${dirname(each.value.file)}",
    "sudo chown ${each.value.user}:${each.value.user} ${each.value.home_dir}/.ssh",
    "sudo chmod 0700 ${each.value.home_dir}/.ssh",
  ]

  file {
    content     = each.value.key
    destination = each.value.file
    permissions = "0644"
    owner       = "root"
    group       = "root"
  }

  commands = [
    "sudo cat ${dirname(each.value.file)}/* > ${each.value.home_dir}/.ssh/authorized_keys || true",
    "sudo chmod 0644 ${each.value.home_dir}/.ssh/authorized_keys", # authorized keys file is owned by root but can be read by anyone.
  ]
}

resource "ssh_resource" "cleanup_key" {
  for_each = {
    for key in local.user_keys_to_cleanup : "${key.user}.${key.name}" => key
  }

  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key
  agent       = var.connection.agent

  when = "destroy"

  commands = [
    "sudo rm -f ${each.value.file}",
    "sudo cat ${dirname(each.value.file)}/* > ${each.value.home_dir}/.ssh/authorized_keys || true",
    "sudo chmod 0644 ${each.value.home_dir}/.ssh/authorized_keys",
  ]
}

resource "ssh_resource" "user_group" {
  for_each = {
    for pair in local.user_groups : "${pair.user}.${pair.group}" => pair
  }

  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key
  agent       = var.connection.agent

  when = "create"

  commands = [
    "sudo usermod -aG ${each.value.group} ${each.value.user}"
  ]
}

resource "ssh_resource" "sudoer" {
  for_each = local.users_sudoers

  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key
  agent       = var.connection.agent

  when = "create"

  file {
    content     = "${each.key} ALL=(ALL) NOPASSWD: ALL\n"
    destination = "/etc/sudoers.d/${each.key}"
    permissions = "0600"
    owner       = "root"
    group       = "root"
  }
}

resource "ssh_resource" "cleanup" {
  for_each = toset(compact([join(",", toset(concat(
    [for user in local.users_to_cleanup : user],
    [for user in local.users_sudoers_to_cleanup : user],
  )))]))

  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key
  agent       = var.connection.agent

  when = "destroy"

  commands = concat(
    [for user in local.users_sudoers_to_cleanup : "sudo rm -f /etc/sudoers.d/${user}"],
    [for user in local.users_to_cleanup : "sudo deluser --remove-home ${user}"],
    [for user in local.users_to_cleanup : "sudo deluser --group --only-if-empty ${user} || true"] # FIXME check if group is not deleted automatically
  )
}
