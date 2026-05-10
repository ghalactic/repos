data "grafana_cloud_organization" "this" {
  provider = grafana.cloud

  slug = module.constants.org
}

resource "grafana_cloud_stack" "this" {
  provider = grafana.cloud

  name        = "ghalactic.grafana.net"
  slug        = "ghalactic"
  region_slug = "prod-us-east-3"
}

resource "grafana_cloud_access_policy" "github_actions" {
  provider = grafana.cloud

  name         = "github-actions"
  display_name = "GitHub Actions"
  region       = "us"

  scopes = ["logs:write"]

  realm {
    type       = "org"
    identifier = data.grafana_cloud_organization.this.id
  }
}

resource "grafana_cloud_access_policy_token" "github_actions_workflows" {
  provider = grafana.cloud

  name             = "github-actions-workflows"
  display_name     = "Workflows"
  region           = "us"
  access_policy_id = grafana_cloud_access_policy.github_actions.policy_id
}

resource "grafana_cloud_stack_service_account" "this" {
  provider = grafana.cloud

  stack_slug = grafana_cloud_stack.this.slug
  name       = "terraform"
  role       = "Admin"
}

resource "grafana_cloud_stack_service_account_token" "this" {
  provider = grafana.cloud

  stack_slug         = grafana_cloud_stack.this.slug
  name               = "terraform"
  service_account_id = grafana_cloud_stack_service_account.this.id
}

resource "github_actions_organization_variable" "otlp_endpoint" {
  variable_name = "OTLP_ENDPOINT"
  value         = "https://otlp-gateway-${grafana_cloud_stack.this.region_slug}.grafana.net/otlp"
  visibility    = "all"
}

resource "github_actions_organization_variable" "otlp_username" {
  variable_name = "OTLP_USERNAME"
  value         = grafana_cloud_stack.this.id
  visibility    = "all"
}

resource "github_actions_organization_secret" "otlp_password" {
  secret_name = "OTLP_PASSWORD"
  value       = grafana_cloud_access_policy_token.github_actions_workflows.token
  visibility  = "all"
}

resource "grafana_folder" "actions" {
  title = "GitHub Actions"
}
