provider "github" {
  owner = module.constants.org

  app_auth {
    id              = var.GITHUB_APP_ID
    installation_id = var.GITHUB_APP_INSTALLATION_ID
    pem_file        = var.GITHUB_APP_PEM_FILE
  }
}

provider "grafana" {
  alias                     = "cloud"
  cloud_access_policy_token = var.GRAFANA_CLOUD_ACCESS_POLICY_TOKEN
}

provider "grafana" {
  url  = grafana_cloud_stack.this.url
  auth = grafana_cloud_stack_service_account_token.this.key
}
