locals {
   env = var.environment == "test2" ? "test" : var.environment
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