# Connection Module

Helper module to parse a connection string and return a map of connection parameters, common across other providers.

## Usage example

```hcl
module "connection" {
  source = "github.com/MykolaBilyi/terraform-modules//connection?ref=v0.6"

  connection_string = "ssh://user:password@host"
}
```
