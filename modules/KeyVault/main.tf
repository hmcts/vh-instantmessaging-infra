data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "vh-im-infra" {
  name = var.resource_group_name
}

resource "azurerm_key_vault" "vh-im-infra" {
  name     = "vhiminfra${var.env_suffix}" 
  resource_group_name = data.azurerm_resource_group.vh-im-infra.name
  location = data.azurerm_resource_group.vh-im-infra.location
  enabled_for_disk_encryption = false
  tenant_id = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  
  network_acls {
    default_action  = "Allow"
    bypass          = "AzureServices"
    ip_rules        = [ "37.228.204.188" ]
  }

  
}

output "kv_name" {
  value = azurerm_key_vault.vh-im-infra.name
}

resource "azurerm_key_vault_access_policy" "policy" {
  for_each                = var.policies
  key_vault_id            = azurerm_key_vault.vh-im-infra.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = lookup(each.value, "object_id")
  key_permissions         = lookup(each.value, "key_permissions")
  secret_permissions      = lookup(each.value, "secret_permissions")
  certificate_permissions = lookup(each.value, "certificate_permissions")
  storage_permissions     = lookup(each.value, "storage_permissions")
}
