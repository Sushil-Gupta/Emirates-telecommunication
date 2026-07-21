module "vm" {
  for_each = var.virtual_machine
  source   = "Azure/avm-res-compute-virtualmachine/azurerm"
  version  = "0.19.3"

  name                   = each.value.name
  location               = each.value.location
  resource_group_name    = each.value.resource_group_name
  os_type                = each.value.os_type
  sku_size               = each.value.sku_size
  zone                   = each.value.zone
  source_image_reference = each.value.source_image_reference

  managed_identities = {
    system_assigned            = each.value.managed_identities.system_assigned
    user_assigned_resource_ids = setunion(toset([tostring(module.managed_identity.resource_id)]), each.value.managed_identities.user_assigned_resource_ids)
  }

  role_assignments = {
    for ra in each.value.role_assignments : ra.name => {
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

  network_interfaces = {
    for nic in each.value.network_interfaces : nic.name => {
      name = nic.name
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "ipconfig-${nic.name}"
          private_ip_subnet_resource_id = module.subnets[each.value.subnet_key].resource_id
        }
      }

    }
  }
  data_disk_managed_disks = {
    for disk in each.value.data_disk : disk.name => {
      name                 = disk.name
      storage_account_type = disk.storage_account_type
      lun                  = 0
      caching              = disk.caching
      disk_size_gb         = disk.disk_size_gb
      tags                 = merge(each.value.tags, local.tags)
    }
  }
  #   diagnostic_settings = {
  #     default = {
  #       name                  = "diag-vm-${each.key}-${var.environment}-${var.app_name}-${var.instance}"
  #       workspace_resource_id = data.azurerm_log_analytics_workspace.monitor.id
  #       log_categories        = ["audit"]
  #       log_groups            = []
  #       metric_categories     = []
  #     }
  #   }

  tags = merge(each.value.tags, local.tags)

  depends_on = [module.subnets, module.managed_identity, module.log_analytics_workspace]
}