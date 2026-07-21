variable "virtual_machine" {
  description = "Configuration for Azure Virtual Machines"
  type = map(object({
    name                       = string
    resource_group_name        = string
    location                   = string
    os_type                    = string
    subnet_key                 = string
    sku_size                   = string
    zone                       = optional(string, null)
    encryption_at_host_enabled = optional(bool, true)
    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    # os_disk = object({
    #   caching              = optional(string, "ReadWrite")
    #   disk_size_gb         = optional(number, 30)
    #   storage_account_type = optional(string, "Premium_LRS")
    # })
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id_or_key                    = string
      is_key                                 = optional(bool, true)
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    managed_identities = optional(object({
      system_assigned = optional(bool, false)
      # user_assigned_resource_keys = optional(set(string), [])
      user_assigned_resource_ids = optional(set(string), [])
    }), {})
    network_interfaces = optional(map(object({
      name = string
      ip_configurations = optional(map(object({
        name = string
        app_gateway_backend_pools = optional(map(object({
          app_gateway_backend_pool_resource_id = string
        })), {})
        create_public_ip_address                                    = optional(bool, false)
        gateway_load_balancer_frontend_ip_configuration_resource_id = optional(string)
        is_primary_ipconfiguration                                  = optional(bool, true)
        load_balancer_backend_pools = optional(map(object({
          load_balancer_backend_pool_resource_id = string
        })), {})
        load_balancer_nat_rules = optional(map(object({
          load_balancer_nat_rule_resource_id = string
        })), {})
        private_ip_address            = optional(string)
        private_ip_address_allocation = optional(string, "Dynamic")
        private_ip_address_version    = optional(string, "IPv4")
        private_ip_subnet_resource_id = optional(string)
        public_ip_address_lock_name   = optional(string)
        public_ip_address_name        = optional(string)
        public_ip_address_resource_id = optional(string)
      })))
      accelerated_networking_enabled = optional(bool, false)
      application_security_groups = optional(map(object({
        application_security_group_resource_id = string
      })), {})
      diagnostic_settings = optional(map(object({
        name                                     = optional(string, null)
        log_categories                           = optional(set(string), [])
        log_groups                               = optional(set(string), [])
        metric_categories                        = optional(set(string), ["AllMetrics"])
        log_analytics_destination_type           = optional(string, null)
        workspace_resource_id                    = optional(string, null)
        storage_account_resource_id              = optional(string, null)
        event_hub_authorization_rule_resource_id = optional(string, null)
        event_hub_name                           = optional(string, null)
        marketplace_partner_resource_id          = optional(string, null)
      })), {})
      dns_servers             = optional(list(string))
      inherit_tags            = optional(bool, true)
      internal_dns_name_label = optional(string)
      ip_forwarding_enabled   = optional(bool, false)
      is_primary              = optional(bool, false)
      lock_level              = optional(string)
      lock_name               = optional(string)
      network_security_groups = optional(map(object({
        network_security_group_resource_id = string
      })), {})
      resource_group_name = optional(string)
      role_assignments = optional(map(object({
        principal_id                           = string
        role_definition_id_or_name             = string
        assign_to_child_public_ip_addresses    = optional(bool, true)
        condition                              = optional(string, null)
        condition_version                      = optional(string, null)
        delegated_managed_identity_resource_id = optional(string, null)
        description                            = optional(string, null)
        skip_service_principal_aad_check       = optional(bool, false)
        principal_type                         = optional(string, null)
      })), {})
      tags = optional(map(string), null)
    })))
    data_disk = map(object({
      name                 = string
      storage_account_type = string
      caching              = optional(string, "None")
      disk_size_gb         = number
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}