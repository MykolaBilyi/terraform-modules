variable "connection" {
  type = object({
    user        = string
    private_key = optional(string)
    agent       = optional(bool)
    host        = string
  })
}

variable "algorithms" {
  type = list(string)
  default = [
    "rsa",
    "ecdsa",
    "ed25519",
  ]
  validation {
    condition     = length(setsubtract([for algo in var.algorithms : lower(algo)], ["dsa", "rsa", "ecdsa", "ed25519"])) == 0
    error_message = "Supported algorithms are dsa, rsa, ecdsa, ed25519"
  }
}

variable "force_regenerate" {
  type    = bool
  default = false
}
