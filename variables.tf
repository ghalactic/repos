module "constants" {
  source = "./modules/constants"
}

variable "GITHUB_APP_ID" {
  type = string
}

variable "GITHUB_APP_INSTALLATION_ID" {
  type = string
}

variable "GITHUB_APP_PEM_FILE" {
  type      = string
  sensitive = true
}
