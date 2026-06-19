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

  grafana_folder_uid = grafana_folder.actions.uid

  grafana_loki_datasource_uid    = data.grafana_data_source.loki.uid
  grafana_alerting_contact_point = grafana_contact_point.this.name

  observe_workflows = {
    "renovate.yml" = {
      title            = "Scheduled maintenance runs for ghalactic/renovate"
      warning_seconds  = 5400
      critical_seconds = 7200
    }
  }
}

module "repo_token_provider" {
  source      = "./modules/repo"
  name        = "token-provider"
  description = "Provisions GitHub tokens for Ghalactic"

  grafana_folder_uid = grafana_folder.actions.uid

  grafana_loki_datasource_uid    = data.grafana_data_source.loki.uid
  grafana_alerting_contact_point = grafana_contact_point.this.name

  observe_workflows = {
    "provision-tokens.yml" = {
      title            = "Scheduled token provisioning runs for ghalactic/token-provider"
      warning_seconds  = 2700
      critical_seconds = 3600
    }
  }
}

module "repo_repo_scheduler" {
  source      = "./modules/repo"
  name        = "repo-scheduler"
  description = "Schedules repository events for more reliable GitHub Actions workflow runs"

  topics = [
    "actions",
    "github-actions",
    "scheduling",
    "automation",
    "cron",
    "dispatch",
  ]

  renovate_post_upgrade_command = "make regenerate"

  has_discussions = true
}

removed {
  from = module.repo_repo_scheduler_cloudflare_token_provider.github_repository.this

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.repo_repo_scheduler_cloudflare_token_provider.github_repository_vulnerability_alerts.this

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.repo_repo_scheduler_cloudflare_token_provider.github_actions_repository_permissions.this

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.repo_repo_scheduler_cloudflare_token_provider.github_branch_protection.default_branch

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.repo_repo_scheduler_cloudflare_token_provider.github_team_repository.renovate_reviewers

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.repo_repo_scheduler_cloudflare_token_provider.github_issue_labels.this

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.repo_repo_scheduler_cloudflare_token_provider.github_repository_file.license

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.repo_repo_scheduler_cloudflare_token_provider.github_repository_file.dot_github_renovate_json

  lifecycle {
    destroy = false
  }
}
