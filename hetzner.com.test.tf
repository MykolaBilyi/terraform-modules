module "vps" {
  source = "./hetzner.com"

  name       = "test"
  public_key = file("~/.ssh/id_rsa.pub")

  init_script = <<EOF
#!/bin/bash
sed -i -E 's/#?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i -E 's/#?PubkeyAuthentication no/PubkeyAuthentication yes/' /etc/ssh/sshd_config
service ssh restart
EOF

  hetzner_vps_image  = "docker-ce"
  hetzner_vps_type   = "cx11"
  hetzner_datacenter = "fsn1-dc14"
  hetzner_labels = {
    "Name" : "test",
  }

  providers = {
    hcloud = hcloud.hetzner
  }
}

module "connection" {
  source = "./connection"

  default_user = "root"
  default_port = 22
  string       = "ssh://${module.vps.server_ip}"
  agent        = true
}

resource "terraform_data" "remove_host_key" {
  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${module.vps.server_ip}"
  }

  depends_on = [ module.vps ]
}

check "host_keys" {
  data "external" "host_keys" {
    program = ["bash", "${path.module}/test-json-helper.sh", "ssh-keyscan", module.vps.server_ip]
  }

  assert {
    condition     = 0 == length(setsubtract(split("\n", data.external.host_keys.result.output), [for k in module.vps.server_host_keys : trimspace("${module.vps.server_ip} ${k}")]))
    error_message = <<EOF
    Host keys are not equal:
    `ssh-keyscan ${module.vps.server_ip}`:
    ${data.external.host_keys.result.output}
    
    Expected:
    ${join("\n", [for k in module.vps.server_host_keys : trimspace("${module.vps.server_ip} ${k}")])}
    EOF
  }
}

provider "hcloud" {
  alias = "hetzner"
}

output "server_ip" {
  value = module.vps.server_ip
}
