# Hetzner.com

Module to create a VPS on Hetzner.com

## Usage example

```hcl
provider "hcloud" {
  token = var.hcloud_token
  alias = "hetzner"
}

module "vps" {
  source = "github.com/MykolaBilyi/terraform-modules//hetzner.com?ref=v0.5"

  name = "test"
  domain_name = "example.com"
  public_key  = var.public_key

  init_script = <<EOF
#!/bin/bash

sed -i -E 's/#?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
ufw allow 22/tcp
service ssh restart

apt-get update
EOF

  hetzner_vps_image  = "docker-ce"
  hetzner_vps_type   = "cx21"
  hetzner_datacenter = "fsn1-dc14"
  hetzner_labels = {
    "Name" : var.project_name,
  }

  providers = {
    hcloud = hcloud.hetzner
  }
}
```
