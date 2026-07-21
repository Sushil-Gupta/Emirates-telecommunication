## Key Vault variables
variable "key_vault" {
  description = "Configuration for Azure Key Vault"
  type = object({
    name     = string
    sku_name = string
    private_endpoints = map(object({
      subnet_key         = string
      subresource_name   = string
      privatednszone_key = string
    }))
    tags                       = optional(map(string), {})
    soft_delete_retention_days = optional(number, 7)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    keys = optional(map(object({
      key_type        = string
      key_size        = optional(number, null)
      key_ops         = optional(list(string), [])
      enabled         = optional(bool, true)
      expiration_date = optional(string, null)
      tags            = optional(map(string), {})
    })), {})
    secrets = optional(map(object({
      value           = string
      content_type    = optional(string, null)
      enabled         = optional(bool, true)
      expiration_date = optional(string, null)
      tags            = optional(map(string), {})
    })), {})
    network_acls = optional(object({
      bypass                     = optional(string, "None")
      default_action             = optional(string, "Deny")
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }), {})
    log_categories    = optional(list(string), ["allLogs"])
    log_groups        = optional(list(string), [])
    metric_categories = optional(list(string), [])
  })
}