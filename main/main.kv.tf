### Key Vault
module "keyvault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.1"

  name                = var.key_vault.name
  resource_group_name = var.spoke_resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.this.tenant_id
  sku_name            = var.key_vault.sku_name
  role_assignments = merge({
    runner_kv_admin_role = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = module.managed_identity.principal_id
    }
    },
    var.key_vault.role_assignments
  )
  network_acls = var.key_vault.network_acls
  private_endpoints = {
    for pe in var.key_vault.private_endpoints : "${var.key_vault.name}-pe" => {
      name                          = "${var.key_vault.name}-pe"
      subnet_resource_id            = module.subnets[pe.subnet_key].resource_id
      private_dns_zone_resource_ids = [module.private_dns[pe.privatednszone_key].resource_id]
      tags                          = merge(var.key_vault.tags, var.tags)
    }
  }
  soft_delete_retention_days = var.key_vault.soft_delete_retention_days
  keys = var.key_vault.keys != {} ? {
    for key, value in var.key_vault.keys : key => merge({ name = "kvk-${key}-${var.environment}-${var.app_name}${var.instance}" }, value)
  } : null
  secrets = var.key_vault.secrets != {} ? {
    for secret, value in var.key_vault.secrets : secret => merge({ name = "kvs-${secret}-${var.environment}-${var.app_name}${var.instance}" }, value)
  } : null
  tags = merge(var.key_vault.tags, var.tags)
  diagnostic_settings = {
    default = {
      name                  = "diag-${var.key_vault.name}"
      workspace_resource_id = module.log_analytics_workspace.resource_id
      # log_categories        = var.key_vault.log_categories
      # log_groups            = var.key_vault.log_groups
      # metric_categories     = var.key_vault.metric_categories
    }
  }

  depends_on = [module.private_dns, module.subnets, module.managed_identity, module.log_analytics_workspace]
}