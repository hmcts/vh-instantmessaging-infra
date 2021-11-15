terraform {
  backend "azurerm" {
    tenant_id       = "531ff96d-0ae9-462a-8d2d-bec7c0b42082"
    subscription_id = "705b2731-0e0b-4df7-8630-95f157f0a347"
  }

}

provider "azurerm" {
  features {}
}