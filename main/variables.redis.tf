variable "redis" {
  description = "Redis configuration"
  type = object({
    name                                    = string
    resource_group_name                     = string
    location                                = string
    enable_telemetry                        = optional(bool, true)
    access_keys_authentication_enabled      = optional(bool, true)
    public_network_access_enabled           = optional(bool, false)
    enable_non_ssl_port                     = optional(bool, false)
    private_endpoints_manage_dns_zone_group = optional(bool, true)
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags = optional(map(string), null)
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
    private_endpoints = map(object({
      name = optional(string, null)
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
      lock = optional(object({
        kind = string
        name = optional(string, null)
      }), null)
      tags                                    = optional(map(string), null)
      subnet_key                              = string
      privatednszone_key                      = string
      subresource_name                        = optional(string, null)
      private_dns_zone_group_name             = optional(string, "default")
      private_dns_zone_resource_ids           = optional(set(string), [])
      application_security_group_associations = optional(map(string), {})
      private_service_connection_name         = optional(string, null)
      network_interface_name                  = optional(string, null)
      location                                = optional(string, null)
      resource_group_name                     = optional(string, null)
      ip_configurations = optional(map(object({
        name               = string
        private_ip_address = string
      })), {})
    }))
    managed_identities = optional(object({
      system_assigned = optional(bool, false)
      # user_assigned_resource_keys = optional(set(string), [])
      user_assigned_resource_ids = optional(set(string), [])
    }), {})
    cache_access_policies = optional(map(object({
      name        = string
      permissions = string
    })), {})
    cache_access_policy_assignments = optional(map(object({
      name               = string
      access_policy_name = string
      object_id          = string
      object_id_alias    = string
    })), {})

    cache_firewall_rules = optional(map(object({
      name     = string
      start_ip = string
      end_ip   = string
    })), {})

    capacity = optional(number, 2)
    linked_redis_caches = optional(map(object({
      linked_redis_cache_resource_id = string
      linked_redis_cache_location    = string
      server_role                    = string
    })), {})
    minimum_tls_version = optional(string, "1.2")
    patch_schedule = optional(set(object({
      day_of_week        = optional(string, "Saturday")
      maintenance_window = optional(string, "PT5H")
      start_hour_utc     = optional(number, 0)
    })), [])
    redis_configuration = optional(object({
      aof_backup_enabled                       = optional(bool)
      aof_storage_connection_string_0          = optional(string)
      aof_storage_connection_string_1          = optional(string)
      enable_authentication                    = optional(bool)
      active_directory_authentication_enabled  = optional(bool)
      maxmemory_reserved                       = optional(number)
      maxmemory_delta                          = optional(number)
      maxfragmentationmemory_reserved          = optional(number)
      maxmemory_policy                         = optional(string)
      data_persistence_authentication_method   = optional(string) #TODO: research the managed identity vs. SAS key and determine level of effort required to default to ManagedIdentity as the more secure option, and review what happens if data persistence is not enabled.
      rdb_backup_enabled                       = optional(bool)   #TODO: Research if we want backups to be true. Given this is cache, probably not required.
      rdb_backup_frequency                     = optional(number)
      rdb_backup_max_snapshot_count            = optional(number)
      rdb_storage_connection_string            = optional(string)
      storage_account_subscription_resource_id = optional(string)
      notify_keyspace_events                   = optional(string)
    }), {})
    redis_version        = optional(number, 6)
    replicas_per_master  = optional(number, null)
    replicas_per_primary = optional(number, null)
    shard_count          = optional(number, null)
    sku_name             = optional(string, "Standard")
    subnet_resource_key  = optional(string, null)
    tenant_settings      = optional(map(string), {})
    zones                = optional(list(string), ["1", "2", "3"])
    # diagnostic_settings
    # private_static_ip_address
  })
}