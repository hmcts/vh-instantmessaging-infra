data "azurerm_resource_group" "vh-im-infra" {
  name = var.resource_group_name
}

#ata "azurerm_app_service_plan" "appplan" {
# name = var.appplan_name
# resource_group_name = var.appplan_rg
#

resource "azurerm_app_service_plan" "appplan" {
  name                = "vh-core-infra${var.env_suffix}"
  location            = "ukwest"
  resource_group_name = "vh-core-infra${var.env_suffix}"

  kind = "app"

  tags = {
    "displayName" = "App Service Plan"
  }

  sku {
    tier = "PremiumV2"
    size = "P2v2"
  }

  per_site_scaling = false
  reserved         = false
}

resource "azurerm_app_service" "app-service" {
  for_each = var.apps

  name     = each.value.name
  location = data.azurerm_resource_group.vh-im-infra.location
  resource_group_name = data.azurerm_resource_group.vh-im-infra.name
  app_service_plan_id = azurerm_app_service_plan.appplan.id

  https_only = true

  site_config {
    dotnet_framework_version  = "v4.0"
    always_on                 = true
    websockets_enabled        = false
    use_32_bit_worker_process = false

    default_documents = []

    cors {
      allowed_origins     = []
      support_credentials = false
    }
  }

  auth_settings {
    enabled = false
  }  

}


resource "azurerm_app_service_slot" "staging" {
  for_each = var.apps
  name                = "staging"
  location            = azurerm_app_service.app-service[each.key].location
  resource_group_name = azurerm_app_service.app-service[each.key].resource_group_name
  app_service_plan_id = azurerm_app_service.app-service[each.key].app_service_plan_id
  app_service_name    = each.value.name

   https_only = true

  site_config {
    dotnet_framework_version  = "v4.0"
    always_on                 = true
    websockets_enabled        = false
    use_32_bit_worker_process = false

    default_documents = []

    cors {
      allowed_origins     = []
      support_credentials = false
    }
  }

  auth_settings {
    enabled = false
  }  
}
