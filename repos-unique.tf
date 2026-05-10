module "repo_branding" {
  source       = "./modules/repo"
  name         = "branding"
  description  = "Branding assets for Ghalactic"
  homepage_url = "https://ghalactic.github.io/branding"

  pages_branch = "gh-pages"
}

module "repo_vale_style" {
  source      = "./modules/repo"
  name        = "vale-style"
  description = "Vale style configuration for Ghalactic"
}

module "repo_org_dot_github_dot_io" {
  source       = "./modules/repo"
  name         = "ghalactic.github.io"
  description  = "The Ghalactic website"
  homepage_url = "https://ghalactic.github.io"

  pages_branch = "main"
}

module "repo_renovate" {
  source       = "./modules/repo"
  name         = "renovate"
  description  = "Self-hosted Renovate for Ghalactic"
  homepage_url = "https://github.com/ghalactic/renovate/actions/workflows/renovate.yml"

  manage_renovate = false

  observe_workflows = {
    "renovate.yml" = {
      title = "Scheduled maintenance runs for ghalactic/renovate"
      last_run_started_thresholds = [
        { value = 0, color = module.constants.grafana_threshold_colors.green },
        { value = 5400, color = module.constants.grafana_threshold_colors.yellow },
        { value = 7200, color = module.constants.grafana_threshold_colors.red },
      ]
    }
  }
}

module "repo_token_provider" {
  source      = "./modules/repo"
  name        = "token-provider"
  description = "Provisions GitHub tokens for Ghalactic"

  observe_workflows = {
    "provision-tokens.yml" = {
      title = "Scheduled token provisioning runs for ghalactic/token-provider"
      last_run_started_thresholds = [
        { value = 0, color = module.constants.grafana_threshold_colors.green },
        { value = 2700, color = module.constants.grafana_threshold_colors.yellow },
        { value = 3600, color = module.constants.grafana_threshold_colors.red },
      ]
    }
  }
}
