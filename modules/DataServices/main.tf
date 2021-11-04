data "azurerm_resource_group" "vh-im-infra" {
  name = var.resource_group_name
}

data "azurerm_key_vault" "vh-im-infra" {
  name = var.kv_name
  resource_group_name = var.resource_group_name  
}

resource "azurerm_user_assigned_identity" "sqluser" {

  name = "vh-im-infra-${var.env_suffix}-sqluser"
  resource_group_name = data.azurerm_resource_group.vh-im-infra.name
  location            = data.azurerm_resource_group.vh-im-infra.location
}

resource "random_password" "sqlpass" {
  length           = 32
  special          = true
  override_special = "_%@"
}

resource "azurerm_sql_server" "vh-im-infra" {
  name                         = "vh-im-core${var.env_suffix}"
  resource_group_name          = data.azurerm_resource_group.vh-im-infra.name
  location                     = data.azurerm_resource_group.vh-im-infra.location
  version                      = "12.0"
  administrator_login          = "hvhearingsapiadmin"
  administrator_login_password = random_password.sqlpass.result

  tags = {
    displayName = "Virtual Courtroom SQL Server"
  }
}

resource "azurerm_key_vault_secret" "VhIMDatabaseConnectionString" {
  name         = "VhIMDatabaseConnectionString"
  value        = "Server=tcp:${azurerm_sql_server.vh-im-infra.name}.database.windows.net,1433;Initial Catalog=vhinstantmessaging;Persist Security Info=False;User ID=${azurerm_sql_server.vh-im-infra.administrator_login};Password=${random_password.sqlpass.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = data.azurerm_key_vault.vh-im-infra.id
}

resource "azurerm_sql_database" "vh-im-infra" {

  name                = "vhinstantmessagingdatabase${var.env_suffix}"
  resource_group_name = azurerm_sql_server.vh-im-infra.resource_group_name
  location            = azurerm_sql_server.vh-im-infra.location
  server_name         = azurerm_sql_server.vh-im-infra.name

  edition                          = "Standard"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  requested_service_objective_name = "S0"
}