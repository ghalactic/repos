# Top-level Grafana Cloud resources

import {
  to = grafana_cloud_stack.this
  id = "ghalactic"
}

import {
  to = grafana_cloud_access_policy.github_actions
  id = "us:706a8676-34b4-4f90-b7ad-54d198d09312"
}

# GitHub org variables and secret

import {
  to = github_actions_organization_variable.otlp_endpoint
  id = "OTLP_ENDPOINT"
}

import {
  to = github_actions_organization_variable.otlp_username
  id = "OTLP_USERNAME"
}

import {
  to = github_actions_organization_secret.otlp_password
  id = "OTLP_PASSWORD"
}

# Per-repo observer workflow files (token-provider)

import {
  to = module.repo_token_provider.github_repository_file.observe_workflow_runs[0]
  id = "token-provider:.github/workflows/observe-workflow-runs.yml:main"
}

import {
  to = module.repo_token_provider.github_repository_file.observe_workflow_changes[0]
  id = "token-provider:.github/workflows/observe-workflow-changes.yml:main"
}

# Per-repo observer workflow files (renovate)

import {
  to = module.repo_renovate.github_repository_file.observe_workflow_runs[0]
  id = "renovate:.github/workflows/observe-workflow-runs.yml:main"
}

import {
  to = module.repo_renovate.github_repository_file.observe_workflow_changes[0]
  id = "renovate:.github/workflows/observe-workflow-changes.yml:main"
}

# Grafana dashboards

import {
  to = module.repo_token_provider.grafana_dashboard.observed_workflow["provision-tokens.yml"]
  id = "9296af63-be53-4e21-a4e6-c58be5228b49"
}

import {
  to = module.repo_renovate.grafana_dashboard.observed_workflow["renovate.yml"]
  id = "fad372cb-618a-4fc6-b709-d4ab912ed8db"
}
