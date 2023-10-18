data "restapi_object" "record" {
  path         = "/dns"
  results_key  = "domains"
  search_key   = "name"
  search_value = var.domain_name
  id_attribute = "id"
}

resource "restapi_object" "record" {
  path = "/dns"

  create_path    = "/dns/{id}"
  update_method  = "POST"
  destroy_method = "GET"
  object_id      = data.restapi_object.record.id
  data = jsonencode({
    "name"              = var.domain_name
    "ipv4Address"       = var.ipv4_address
    "ipv6Address"       = var.ipv6_address
    "ipv4"              = true,
    "ipv6"              = var.ipv6_address == "" ? false : true,
    "ipv4WildcardAlias" = true,
    "ipv6WildcardAlias" = var.ipv6_address == "" ? false : true,
  })
}