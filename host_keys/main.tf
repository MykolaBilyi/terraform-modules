locals {
  params = {
    "rsa" = "rsa -b 4096"
  }

  algorithms = toset([for algo in var.algorithms : lower(algo)])
  commands   = { for algo in local.algorithms : algo => "ssh-keygen -q -N '' -C '' -t ${lookup(local.params, algo, algo)} -f /etc/ssh/ssh_host_${algo}_key" }
}

resource "ssh_resource" "keys" {
  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key
  agent       = var.connection.agent

  commands = concat([
    "rm -f `${join(" | ", concat(["ls /etc/ssh/ssh_host_*_key*"], [for algo in local.algorithms : "grep -v ssh_host_${algo}_key"]))}`",
    ], var.force_regenerate ?
    [for algo, cmd in local.commands : "rm -f /etc/ssh/ssh_host_${algo}_key* && ${cmd}"] :
    [for algo, cmd in local.commands : "test -e /etc/ssh/ssh_host_${algo}_key || ${cmd}"], [
      "sudo chown root:root /etc/ssh/ssh_host_*_key*",
      "sudo chmod 0600 /etc/ssh/ssh_host_*_key",
      "sudo chmod 0644 /etc/ssh/ssh_host_*_key.pub",
      "sudo cat /etc/ssh/ssh_host_*_key.pub | cut -d ' ' -f 1-2",
  ])
}
