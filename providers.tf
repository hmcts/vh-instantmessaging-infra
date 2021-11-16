terraform {
  backend "azurerm" {}

  required_version = ">= 0.14.4"
  required_providers {
    azurerm = ">=2.0.0"
  }

}

provider "azurerm" {
  features {}
}