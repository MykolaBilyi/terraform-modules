locals {
  algo_key_id = {
    "ssh-rsa"             = "rsa"
    "ssh-dss"             = "dsa"
    "ecdsa-sha2-nistp256" = "ecdsa"
    "ecdsa-sha2-nistp384" = "ecdsa"
    "ecdsa-sha2-nistp521" = "ecdsa"
    "ssh-ed25519"         = "ed25519"
  }
}

output "keys" {
  value = { for key in compact(split("\n", ssh_resource.keys.result)) : lookup(local.algo_key_id, split(" ", key)[0], split(" ", key)[0]) => trimspace(key) }
}
