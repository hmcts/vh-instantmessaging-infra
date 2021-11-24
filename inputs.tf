variable "tags" {
  type    = map(any)
  default = {}
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "product" {
  type = string
}

variable "builtFrom" {
  type = string
}