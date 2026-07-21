subscription_id                   = "95642268-5116-484d-9b88-7dfce8c20ce4" # Subscription ID where the resources will be provisioned. Ensure that you have the necessary permissions to create resources in this subscription.
spoke_resource_group_name         = "rg-infra-devops-v-sushigupta-demo" # Resource group name where the resources will be created. Ensure that this resource group exists in the specified subscription.
location                          = "uaenorth"
app_name                          = "smilesweb"
environment                       = "dev"
instance                          = ""
spoke_vnet   = {
    name                = "vnet-smilesweb-uaen-nonprod-01"
    address_spaces      = ["10.171.22.0/25","10.171.15.0/27"]
}
hub_vnet   = {
    name                     = "<<HUB VNET NAME>>"
    resource_group_name      = "<<HUB RG NAME>>"
}
route_table = {
    name = "rt-smilesweb-uaen-nonprod-01"
    firewallPrivateIp = "<<HUB FIREWALL IP>>"
}
tags = {
    "environment"  = "dev"
    "Criticality"  = "Low"
    "created_by"   = "Terraform"
    "created_on"   = "2026-07-17"
    "customer_name"  = "Emirates_E&"
    "region"      = "uaenorth"
    "purpose"     = "smilesweb_portal"
    "tower"       = "Azure"
}
log_analytics_workspace = {
    name                = "law-smilesweb-uaen-nonprod-01"
    resource_group_name = "rg-infra-devops-v-sushigupta-demo"
}


subnets = {
  "aks" = {
    name                            = "snet-clusternodes-smilesweb-aks-dev"
    address_prefix                  = "10.171.22.0/26"
    default_outbound_access_enabled = true
  }
  "infra-nonprod" = {
    name                            = "snet-infra-smilesweb-nonprod"
    address_prefix                  = "10.171.15.0/28"
    default_outbound_access_enabled = true
  }
}


private_dns_zones = {
    "aks" = {
      domain_name = "privatelink.uaenorth.azmk8s.io"
    }
    "keyvault" = {
      domain_name = "privatelink.vaultcore.azure.net"
    }
    "acr" = {
      domain_name = "privatelink.azurecr.io"
    }
    "redis" = {
      domain_name = "privatelink.redis.cache.windows.net"
    }
    "storage-blob" = {
      domain_name = "privatelink.blob.core.windows.net"
    }
    "storage-file" = {
      domain_name = "privatelink.file.core.windows.net"
    }
}

nsg = {
  "aks" = {
    name = "nsg-aks-smilesweb-dev"
  }
  
  "infra-nonprod" = {
    name = "nsg-infra-smilesweb-nonprod"
    # Rules for private endpoints + vm traffic
    security_rules = {
      "rule01" = {
        name                       = "rule011"
        access                     = "Deny"
        destination_address_prefix = "*"
        destination_port_range     = "80-88"
        direction                  = "Outbound"
        priority                   = 100
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"
      }
      "rule02" = {
        name                       = "rule012"
        access                     = "Allow"
        destination_address_prefix = "*"
        destination_port_ranges    = ["80", "443"]
        direction                  = "Inbound"
        priority                   = 200
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"
      }
    }
  }
}

azure_kubernetes_service = {
    name                = "aks-smilesweb-dev-01"
    sku_tier                           = "Standard" # Free tier is used for testing purposes. For production workloads, consider using "Paid" tier which offers more features and capabilities.
    oidc_issuer_enabled                = true
    workload_identity_enabled          = true
    role_based_access_control_enabled  = true
    dns_prefix_private_cluster         = "smilesweb-akscluster-private-test"
    private_cluster_enabled            = true
    private_dns_zone_key               = "aks"
    kubernetes_version                 = "1.36.1" # Latest stable. Specify the desired Kubernetes version. Ensure that the chosen version is supported in the target Azure region. 
    private_cluster_public_fqdn_enabled = true
    ingress_application_gateway = {
      gateway_key = "A"
   }
    run_command_enabled = true
    default_node_pool = {
        name                 = "default"
        vm_size              = "standard_A2_v2" # Choose a VM size that supports the required features and is available in the target region
        os_disk_size_gb      = 64 # Specify the size of the OS disk in GB. Adjust this value based on your workload requirements and the size of the container images you plan to use.
        os_sku               = "AzureLinux"
        min_count            = 1
        max_count            = 5
        # node_count           = 1 # fixed count of nodes in the default node pool. This is optional and can be omitted if auto-scaling is enabled.
        auto_scaling_enabled = true
        max_pods             = 30
        vnet_subnet_key       = "aks"
        temporary_name_for_rotation = "default"
      }
    node_pools  = {
       unp1 = {
        name                 = "linuxpool01"
        vm_size              = "standard_E2s_v5" # Choose a VM size that supports the required features and is available in the target region
        os_disk_size_gb      = 128 # Specify the size of the OS disk in GB. Adjust this value based on your workload requirements and the size of the container images you plan to use.
        os_sku               = "AzureLinux"
        min_count            = 1
        max_count            = 20
        # node_count           = 1
        auto_scaling_enabled = true
        max_pods             = 30
        vnet_subnet_key       = "aks"
        temporary_name_for_rotation = "linuxpool01"
      }
    }
    network_profile = {
        network_plugin       = "azure" 
        network_plugin_mode  = "overlay"
        outbound_type        = "loadBalancer"
        # service_cidr         = "10.0.97.192/26"
        # dns_service_ip       = "10.0.97.199"
    }
    # Configure Managed Identity
    managed_identities = {
        system_assigned  = false
        user_assigned_resource_ids = []
    }    
    role_assignments = {
      # rbac_role = {
      #   role_definition_id_or_name = "Azure Kubernetes Service RBAC Reader"
      #   principal_id               = "bbd73755-da5c-4284-a595-1cddb969fe91"
      #   principal_type = "Group"    
      # }
      # cluster_user_role = {
      #   role_definition_id_or_name = "Azure Kubernetes Service Cluster User Role"
      #   principal_id               = "bbd73755-da5c-4284-a595-1cddb969fe91"
      #   principal_type = "Group"    
      # }
      # Namespace_contributor = {
      #   role_definition_id_or_name = "Azure Kubernetes Service Namespace Contributor"
      #   principal_id               = "bbd73755-da5c-4284-a595-1cddb969fe91"
      #   principal_type = "Group"    
      # }
    }
#     private_endpoints = {
#     "primary" = {
#        subnet_key         = "infra-nonprod"
#         privatednszone_key = "aks"
#         subresource_name   = "management"
#     }
#   }
    private_endpoints_manage_dns_zone_group = false
    # Configure Azure AD Role-Based Access Control
    azure_active_directory_role_based_access_control = {
      azure_rbac_enabled = true
      admin_group_object_ids = []
    }
}

# Key Vault
key_vault = {
    name = "akv-smilesweb-test"
    sku_name = "standard"
    tags = {}
    network_acls = {
      bypass                     = "None"
      default_action             = "Deny"
      ip_rules                   = [] # Pass list of IP addresses
    }
    private_endpoints = {
      "akv-smilesweb-test-pe" = {
        subnet_key         = "infra-nonprod"
        privatednszone_key = "keyvault"
        subresource_name   = "vault"
      }
    }
     role_assignments = {
      # rbac_role = {
      #   role_definition_id_or_name = "Key Vault Secrets User"
      #   principal_id               = "bbd73755-da5c-4284-a595-1cddb969fe91"
      #   principal_type = "Group"    
      # }
     }
}
# Container registry
container_registry = {
  name = "acrsmileswebtest"
  resource_group_name = "rg-infra-devops-v-sushigupta-demo"
  sku = "Premium" # Choose the SKU based on your requirements. The Premium SKU is required for private endpoints and offers additional features such as geo-replication and content trust.
  private_endpoints = {
    "primary" = {
      name                         = "acr-smilesweb-test-pe"
       subnet_key         = "infra-nonprod"
        privatednszone_key = "acr"
    }
  }
}
# Storage account
storage_accounts = {
  "stg_acc_key" = {
    name                      = "smileswebteststorage"
    resource_group_name       = "rg-infra-devops-v-sushigupta-demo"
    account_tier              = "Standard"
    storage_accounts_kind      = "StorageV2"
    account_replication_type  = "LRS"
    shared_access_key_enabled = false  # Aligned with Azure Policy enforcement
    private_endpoints = {
      "stg-smilesweb-test-pe-blob" = {
        name               = "stg-smilesweb-test-pe-blob"
        subnet_key         = "infra-nonprod"
        subresource_name   = "blob"
        privatednszone_key = "storage-blob"
      }
      "stg-smilesweb-test-pe-file" = {
        name               = "stg-smilesweb-test-pe-file"
        subnet_key         = "infra-nonprod"
        subresource_name   = "file" 
        privatednszone_key = "storage-file"
    }
  }
}
}
# Redis cache
redis = {
        name                        = "redis-smilesweb-test"
        resource_group_name               = "rg-infra-devops-v-sushigupta-demo"
        location                          = "uaenorth"
        enable_telemetry            = false
		    access_keys_authentication_enabled = true
		    public_network_access_enabled = false
		    enable_non_ssl_port  = false
		    private_endpoints_manage_dns_zone_group = true      
        tags = {}
        # zones = ["1", "2", "3"]
        private_endpoints = {
          "pe-redis-smilesweb-test" = {
            name                            = "pe-redis-smilesweb-test"
            subnet_key                      = "infra-nonprod"
            private_dns_zone_group_name     = "dns-redis-smilesweb-test"
            privatednszone_key              = "redis"
            subresource_name                = "redisCache"
            network_interface_name          = "nic-redis-smilesweb-test"
            private_service_connection_name = "connection-redis-smilesweb-test"
          }
        }
        managed_identities = {
          system_assigned = false
        }
        redis_configuration = {
          maxmemory_reserved = 1330
          maxmemory_delta    = 1330
          maxmemory_policy   = "allkeys-lru"
        }        
        minimum_tls_version = "1.2"
        sku_name = "Basic" # The SKU name for the Redis cache. Options include Basic, Standard, and Premium. The Basic SKU is suitable for development and testing, while Standard and Premium offer higher availability and additional features.
        # applicable only when the subnet is separate for redis and sku is premium
        # subnet_resource_key = ""
}


# DevOps Virtual Machine
virtual_machine = {
  "vm-smilesweb-devops-01-nonprod" = {
    name                = "vm-smilesweb-devops-01-nonprod"
    resource_group_name = "rg-infra-devops-v-sushigupta-demo"
    location            = "uaenorth"
    os_type             = "Linux"
    subnet_key          = "infra-nonprod"
    sku_size            = "Standard_D2s_v5"
    zone                = "2"
    network_interfaces = {
      "nic-vm-smilesweb-devops-01-nonprod" = {
        name = "nic-smilesweb-devops-01-nonprod"
      }
    }
    managed_identities = {
      system_assigned = false
    }
    source_image_reference = {
      publisher = "Canonical"
      offer     = "ubuntu-24_04-lts"
      sku       = "server"
      version   = "latest"
    }
    data_disk = {
      "disk-vm-smilesweb-devops-01-nonprod" = {
        name                 = "disk-vm-smilesweb-devops-01-nonprod"
        storage_account_type = "StandardSSD_LRS"
        disk_size_gb         = 128
        caching              = "ReadWrite"
      }
    }
    tags = {
      type = "Misc"
      purpose = "Non-Prod Devops Agent"
    }
  }

  # Jump Box Virtual Machine
  "vm-smilesweb-jump-01-nonprod" = {
    name                = "vm-smilesweb-jump-01-nonprod"
    resource_group_name = "rg-infra-devops-v-sushigupta-demo"
    location            = "uaenorth"
    os_type             = "Linux"
    subnet_key          = "infra-nonprod"
    sku_size            = "Standard_D2s_v5"
    zone                = "2" # The availability zone where the virtual machine will be deployed. Ensure that the specified zone is available in the target Azure region and supports the chosen VM size.
    network_interfaces = {
      "nic-vm-smilesweb-jump-01-nonprod" = {
        name = "nic-smilesweb-jump-01-nonprod"
      }
    }
    managed_identities = {
      system_assigned = false
    }
    source_image_reference = {
      publisher = "Canonical"
      offer     = "ubuntu-24_04-lts"
      sku       = "server"
      version   = "latest"
    }
    data_disk = {
      "disk-vm-smilesweb-jump-01-nonprod" = {
        name                 = "disk-vm-smilesweb-jump-01-nonprod"
        storage_account_type = "StandardSSD_LRS"
        disk_size_gb         = 128
        caching              = "ReadWrite"
      }
    }
    tags = {
      type = "Misc"
      purpose = "Non-Prod jump box"
    }
  }
}