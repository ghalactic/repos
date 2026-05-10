terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.0"
    }
  }
}

provider "github" {
  owner = module.constants.org

  app_auth {
    id              = var.GITHUB_APP_ID
    installation_id = var.GITHUB_APP_INSTALLATION_ID
    pem_file        = var.GITHUB_APP_PEM_FILE
  }
}

provider "grafana" {
  cloud_access_policy_token = var.GRAFANA_CLOUD_ACCESS_POLICY_TOKEN
  url                       = grafana_cloud_stack.this.url
  auth                      = grafana_cloud_stack_service_account_token.this.key
}
