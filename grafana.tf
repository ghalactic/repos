resource "grafana_cloud_stack" "this" {
  name        = "ghalactic"
  slug        = "ghalactic"
  region_slug = "prod-us-east-3"
}

resource "grafana_cloud_access_policy" "workflow_observability" {
  name         = "workflow-observability"
  display_name = "Workflow observability"
  region       = grafana_cloud_stack.this.region_slug

  scopes = ["logs:write", "metrics:write"]

  realm {
    type       = "stack"
    identifier = grafana_cloud_stack.this.id
  }
}

resource "grafana_cloud_access_policy_token" "workflow_observability" {
  name             = "github-actions-workflows"
  access_policy_id = grafana_cloud_access_policy.workflow_observability.policy_id
  region           = grafana_cloud_stack.this.region_slug
}

resource "grafana_cloud_stack_service_account" "this" {
  stack_slug = grafana_cloud_stack.this.slug
  name       = "terraform"
  role       = "Admin"
}

resource "grafana_cloud_stack_service_account_token" "this" {
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
  secret_name     = "OTLP_PASSWORD"
  plaintext_value = grafana_cloud_access_policy_token.workflow_observability.token
  visibility      = "all"
}
