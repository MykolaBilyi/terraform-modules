# Dynu.com

Module to update DNS record on Dynu.com

## Usage example

```hcl
provider "restapi" {
  uri     = "https://api.dynu.com/v2"
  headers = {
    "API-Key"      = var.dynu_api_key
    "Content-Type" = "application/json"
  }
  alias = "dynu"
}

module "ddns" {
  source = "github.com/MykolaBilyi/terraform-modules//dynu.com?ref=v0.2"

  domain_name  = "example.com"
  ipv4_address = module.vps.server_ip
  ipv6_address = module.vps.server_ipv6

  providers = {
    restapi = restapi.dynu
  }
}
```