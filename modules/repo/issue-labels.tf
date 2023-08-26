locals {
  issue_label_color_renovate        = "0366D6"
  issue_label_color_renovate_safe   = "168700"
  issue_label_color_renovate_unsafe = "D93F0B"
}

resource "github_issue_label" "renovate" {
  repository  = github_repository.this.name
  name        = "renovate"
  description = "Pull requests created by Renovate"
  color       = local.issue_label_color_renovate
}

resource "github_issue_label" "github_actions" {
  repository  = github_repository.this.name
  name        = "github-actions"
  description = "Pull requests that update GitHub Actions dependencies"
  color       = local.issue_label_color_renovate
}

resource "github_issue_label" "npm" {
  repository  = github_repository.this.name
  name        = "npm"
  description = "Pull requests that update NPM dependencies"
  color       = local.issue_label_color_renovate
}

resource "github_issue_label" "terraform" {
  repository  = github_repository.this.name
  name        = "terraform"
  description = "Pull requests that update Terraform dependencies"
  color       = local.issue_label_color_renovate
}

resource "github_issue_label" "major" {
  repository  = github_repository.this.name
  name        = "major"
  description = "Pull requests that update major dependency versions"
  color       = local.issue_label_color_renovate_unsafe
}

resource "github_issue_label" "non_major" {
  repository  = github_repository.this.name
  name        = "non-major"
  description = "Pull requests that update non-major dependency versions"
  color       = local.issue_label_color_renovate_safe
}

resource "github_issue_label" "non_dev" {
  repository  = github_repository.this.name
  name        = "non-dev"
  description = "Pull requests that update non-dev dependencies"
  color       = local.issue_label_color_renovate_unsafe
}

resource "github_issue_label" "dev" {
  repository  = github_repository.this.name
  name        = "dev"
  description = "Pull requests that update dev dependencies"
  color       = local.issue_label_color_renovate_safe
}
