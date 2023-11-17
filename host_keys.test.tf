locals {
  algos = ["rsa", "ecdsa", "ed25519"]
}

module "host_keys" {
  source = "./host_keys"

  connection = module.connection
  algorithms = local.algos
}

check "host_keys" {
  data "external" "host_keys" {
    program = ["bash", "${path.module}/test-json-helper.sh", "ssh-keyscan", module.connection.host]
  }

  assert {
    condition = 0 == length(setunion(
      setsubtract([for a, k in module.host_keys.keys : a], local.algos),
      setsubtract(local.algos, [for a, k in module.host_keys.keys : a]),
    ))
    error_message = "Host key algorithms are not equal: want [${join(" ", local.algos)}], got [${join(" ", [for a, k in module.host_keys.keys : a])}]"
  }


  assert {
    condition = 0 == length(setunion(
      setsubtract(split("\n", data.external.host_keys.result.output), [for k in module.host_keys.keys : trimspace("${module.connection.host} ${k}")]),
      setsubtract([for k in module.host_keys.keys : trimspace("${module.connection.host} ${k}")], split("\n", data.external.host_keys.result.output))
    ))
    error_message = <<EOF
    Host keys are not equal:
    `ssh-keyscan ${module.connection.host}`:
    ${data.external.host_keys.result.output}
    
    Expected:
    ${join("\n", [for k in module.host_keys.keys : trimspace("${module.connection.host} ${k}")])}
    EOF
  }
}
