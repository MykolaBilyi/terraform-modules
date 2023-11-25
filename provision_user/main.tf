locals {
  users = toset([for user in [var.user_name] : {
    name     = user
    home_dir = user == "root" ? "/root" : "/home/${user}"
    shell    = var.shell
    groups   = toset([for group in var.groups : group if group != "sudo" && user != "root"])
  }])
  users_non_root           = toset([for user in local.users : user if user.name != "root"])
  users_to_cleanup         = toset([for user in local.users_non_root : user if var.on_destroy == "delete"])
  users_sudoers            = toset([for user in local.users_non_root : user if contains(var.groups, "sudo")])
  users_sudoers_to_cleanup = toset([for user in local.users_sudoers : user if var.on_destroy == "delete"])

  keys = toset([for key in var.public_keys : {
    name = trimspace(element(concat(split(" ", key), ["key#${md5(key)}"]), 2))
    key  = "${trimspace(key)}\n"
    restrictions = compact([
      var.from != null ? "from=\"${join(",", var.from)}\"" : null,
      var.command != null ? "command=\"${replace(var.command, "\"", "\\\"")}\"" : null,
      var.port-forwarding ? null : "no-port-forwarding",
      var.x11-forwarding ? null : "no-x11-forwarding",
      var.agent-forwarding ? null : "no-agent-forwarding",
      var.pty ? null : "no-pty"
    ])
  }])
  user_keys = toset([
    for pair in setproduct(local.users, local.keys) : {
      name         = pair[1].name
      file         = "${pair[0].home_dir}/.ssh/authorized_keys.d/${pair[1].name}"
      key          = pair[1].key
      restrictions = join(",", pair[1].restrictions)
    }
  ])
  user_keys_to_cleanup = toset([for key in local.user_keys : key if var.on_destroy == "delete_keys"])
}


resource "ssh_resource" "cleanup" {
  count = var.on_destroy == "delete" ? 1 : 0

  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key
  agent       = var.connection.agent

  when = "destroy"

  commands = concat(
    [for user in local.users_sudoers_to_cleanup : "sudo rm -f /etc/sudoers.d/${user.name}"],
    [for user in local.users_to_cleanup : "sudo deluser --remove-home ${user.name}"],
    [for user in local.users_to_cleanup : "sudo deluser --group --only-if-empty ${user.name} || true"] # FIXME check if group is not deleted automatically
  )

  triggers = {
    on_users_change = "${md5(jsonencode(local.users))}"
  }
}

resource "ssh_resource" "users" {
  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key
  agent       = var.connection.agent

  when = "create"

  pre_commands = concat(
    [for user in local.users : "sudo mkdir -p ${user.home_dir}"],
    [for user in local.users : "id -u ${user.name} >/dev/null  2>&1 || sudo useradd -s ${user.shell} ${user.name}"],
    [for user in local.users : "sudo chown ${user.name}:${user.name} ${user.home_dir}"]
  )

  dynamic "file" {
    for_each = local.users_sudoers
    content {
      content     = "${file.value.name} ALL=(ALL) NOPASSWD: ALL\n"
      destination = "/etc/sudoers.d/${file.value.name}"
      permissions = "0600"
      owner       = "root"
      group       = "root"
    }
  }

  commands = flatten([
    [for user in local.users : [for group in user.groups : "sudo usermod -aG ${group} ${user.name}"]],
    "id -u ${var.user_name}"
  ])

  triggers = {
    on_users_change = "${md5(jsonencode(local.users))}"
  }

  depends_on = [ssh_resource.cleanup]
}

resource "ssh_resource" "keys_cleanup" {
  count = var.on_destroy != "keep" ? 1 : 0

  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key
  agent       = var.connection.agent

  when = "destroy"

  commands = concat(
    [for key in local.user_keys_to_cleanup : "sudo rm -f ${key.file}"],
    [for user in local.users : "sudo cat ${user.home_dir}/.ssh/authorized_keys.d/* > ${user.home_dir}/.ssh/authorized_keys || true"],
    [for user in local.users : "sudo chmod 0644 ${user.home_dir}/.ssh/authorized_keys"],
  )

  triggers = {
    on_user_keys_change = "${md5(jsonencode(local.user_keys))}"
  }

  depends_on = [ssh_resource.users]
}

resource "ssh_resource" "keys" {
  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key
  agent       = var.connection.agent

  when = "create"

  pre_commands = concat(
    [for user in local.users : "sudo mkdir -p ${user.home_dir}/.ssh/authorized_keys.d"],
    [for user in local.users : "sudo chown ${user.name}:${user.name} ${user.home_dir}/.ssh"],
    [for user in local.users : "sudo chmod 0700 ${user.home_dir}/.ssh"]
  )

  dynamic "file" {
    for_each = local.user_keys
    content {
      content     = join(" ", compact([file.value.restrictions, file.value.key]))
      destination = file.value.file
      permissions = "0644"
      owner       = "root"
      group       = "root"
    }
  }

  commands = concat(
    [for user in local.users : "sudo cat ${user.home_dir}/.ssh/authorized_keys.d/* > ${user.home_dir}/.ssh/authorized_keys || true"],
    [for user in local.users : "sudo chmod 0644 ${user.home_dir}/.ssh/authorized_keys"] # authorized keys file is owned by root but can be read by anyone.
  )

  triggers = {
    on_users_change     = "${md5(jsonencode(local.users))}"
    on_user_keys_change = "${md5(jsonencode(local.user_keys))}"
  }

  depends_on = [ssh_resource.keys_cleanup]
}
