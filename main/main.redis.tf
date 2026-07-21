locals {
  tags = {}
}

module "redis" {
  source = "Azure/avm-res-cache-redis/azurerm"

  name                                    = var.redis.name
  location                                = var.redis.location
  resource_group_name                     = var.redis.resource_group_name
  public_network_access_enabled           = var.redis.public_network_access_enabled
  sku_name                                = var.redis.sku_name
  tags                                    = merge(local.tags, var.redis.tags)
  zones                                   = null # var.redis.zones
  enable_telemetry                        = var.redis.enable_telemetry
  access_keys_authentication_enabled      = var.redis.access_keys_authentication_enabled
  enable_non_ssl_port                     = var.redis.enable_non_ssl_port
  private_endpoints_manage_dns_zone_group = var.redis.private_endpoints_manage_dns_zone_group
  minimum_tls_version                     = var.redis.minimum_tls_version
  redis_configuration                     = var.redis.redis_configuration
  redis_version                           = var.redis.redis_version
  shard_count                             = var.redis.shard_count
  subnet_resource_id                      = var.redis.subnet_resource_key != null ? module.subnets[var.redis.subnet_key].resource_id : null
  private_endpoints = {
    for pe in var.redis.private_endpoints : var.redis.name => {
      name                            = pe.name
      subnet_resource_id              = module.subnets[pe.subnet_key].resource_id
      private_dns_zone_resource_ids   = [module.private_dns[pe.privatednszone_key].resource_id]
      tags                            = merge(pe.tags, local.tags)
      subresource_name                = pe.subresource_name
      private_service_connection_name = pe.private_service_connection_name
      network_interface_name          = pe.network_interface_name
      private_dns_zone_group_name     = pe.private_dns_zone_group_name
    }
  }
  managed_identities = {
    system_assigned            = var.redis.managed_identities.system_assigned
    user_assigned_resource_ids = setunion(toset([tostring(module.managed_identity.resource_id)]), var.redis.managed_identities.user_assigned_resource_ids)
  }

  role_assignments = {
    for ra in var.redis.role_assignments : ra.name => {
      role_definition_id_or_name             = ra.role_definition_id_or_name
      principal_id                           = ra.is_key ? module.managed_identity[ra.principal_id_or_key].principal_id : ra.principal_id
      description                            = ra.description
      skip_service_principal_aad_check       = ra.skip_service_principal_aad_check
      condition                              = ra.condition
      condition_version                      = ra.condition_version
      delegated_managed_identity_resource_id = ra.delegated_managed_identity_resource_id
      principal_type                         = ra.principal_type
    }
  }

  depends_on = [module.subnets,
  module.managed_identity, module.log_analytics_workspace]
}