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
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = "52432a41-19d7-4372-b9d8-5703f0b4fc2d"


     certificate_permissions = [
      "backup",
      "create",
      "delete",
      "deleteissuers",
      "get",
      "getissuers",
      "import",
      "list",
      "listissuers",
      "managecontacts",
      "manageissuers",
      "purge",
      "recover",
      "restore",
      "setissuers",
      "update"
    ]

    key_permissions = [
      "backup",
      "create",
      "decrypt",
      "delete",
      "encrypt",
      "get",
      "import",
      "list",
      "purge",
      "recover",
      "restore",
      "sign",
      "unwrapKey",
      "update",
      "verify",
      "wrapKey"
    ]

    secret_permissions = [
      "backup",
      "delete",
      "get",
      "list",
      "purge",
      "recover",
      "restore",
      "set"
    ]

    storage_permissions = [
      "backup",
      "delete",
      "deletesas",
      "get",
      "getsas",
      "list",
      "listsas",
      "purge",
      "recover",
      "regeneratekey",
      "restore",
      "set",
      "setsas",
      "update"
    ]
  }
  network_acls {
    default_action  = "Deny"
    bypass          = "AzureServices"
    ip_rules        = [ "37.228.204.188" ]
  }

  
}

output "kv_name" {
  value = azurerm_key_vault.vh-im-infra.name
}
