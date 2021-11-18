variable "workspace_to_environment_map" {
  type = map(any)
  default = {
    AAT     = "aat"
    Demo    = "demo"
    Dev     = "dev"
    Preview = "preview"
    Sandbox = "sandbox"
    Test1   = "test1"
    Test2   = "test2"
    PreProd = "preprod"
    Prod    = "prod"
  }
}

locals {
  environment   = lookup(var.workspace_to_environment_map, terraform.workspace, "dev")
  suffix        = "-${local.environment}"
  common_prefix = "im-infra"
  std_prefix    = "vh-${local.common_prefix}"

  app_definitions = {

    im-web = {
      name       = "vh-im-web${local.suffix}"
      websockets = false
      subnet     = "backend"
    }

    api-web = {
      name       = "vh-im-api${local.suffix}"
      websockets = false
      subnet     = "backend"
    }
  }
}