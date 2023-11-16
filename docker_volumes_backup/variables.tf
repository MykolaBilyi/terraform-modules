variable "connection" {
  type = object({
    user        = string
    private_key = optional(string)
    agent       = optional(bool)
    host        = string
  })
}

variable "backup_config" {
  type        = map(string)
  description = "Rclone config for backup"
}

variable "secrets" {
  type        = map(string)
  sensitive   = true
  description = "Secrets for backup, uploaded to $${RCLONE_CONFIG_DIR}"
}

variable "backup_label" {
  type        = string
  default     = "backup"
  description = "Volume label for backup"
}

variable "config_volume_name" {
  type        = string
  default     = "backup_config"
  description = "Volume name for backup config"
}
