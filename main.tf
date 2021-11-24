locals {
  env = var.environment == "test1" ? "test" : var.environment == "test2" ? "test" : var.environment
}

resource "azurerm_resource_group" "vh-im-infra" {
  name     = "${local.std_prefix}${local.suffix}"
  location = var.location
  tags     = local.common_tags
}

data "azurerm_client_config" "current" {}


module "KeyVault" {
  source = "./modules/KeyVault"

  resource_group_name = azurerm_resource_group.vh-im-infra.name
  env_suffix          = local.suffix

  policies = {
    "devops-agent" = {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = "d7504361-1c3b-4e0c-a1df-ba07cbf59ba9"
      key_permissions         = ["Get", "List", "Delete", "Recover", "Backup", "Restore", "Purge"]
      secret_permissions      = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
      certificate_permissions = []
      storage_permissions     = []
    },
    "chris_c" = {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = "52432a41-19d7-4372-b9d8-5703f0b4fc2d"
      key_permissions         = ["Get", "List", "Delete", "Recover", "Backup", "Restore", "Purge"]
      secret_permissions      = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
      certificate_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore"]
      storage_permissions     = []
    }
  }

  depends_on = [
    azurerm_resource_group.vh-im-infra
  ]

}
module "DataServices" {
  source = "./modules/DataServices"

  resource_group_name = azurerm_resource_group.vh-im-infra.name
  env_suffix          = local.suffix
  kv_name             = module.KeyVault.kv_name

  depends_on = [
    azurerm_resource_group.vh-im-infra,
    module.KeyVault
  ]
}

module "AppService" {
  source = "./modules/AppService"

  apps = {
    for app in keys(local.app_definitions) :
    app => {
      name       = local.app_definitions[app].name
      websockets = local.app_definitions[app].websockets
    }
  }

  resource_group_name = azurerm_resource_group.vh-im-infra.name
  env_suffix          = local.suffix

  depends_on = [
    azurerm_resource_group.vh-im-infra
  ]
}

locals {
  common_tags = module.ctags.common_tags
}

module "ctags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git"
  environment = lower(local.env)
  product     = var.product
  builtFrom   = var.builtFrom
}