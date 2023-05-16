resource "github_repository" "this" {
  archive_on_destroy = true

  name         = var.name
  description  = var.description
  topics       = var.topics
  homepage_url = var.homepage_url
  is_template  = var.is_template
  visibility   = "public"

  auto_init    = true
  has_projects = false
  has_wiki     = false
  has_issues   = !var.is_template

  delete_branch_on_merge = true
  vulnerability_alerts   = true

  dynamic "template" {
    for_each = var.template == null ? [] : [null]

    content {
      owner      = var.template.owner
      repository = var.template.repository
    }
  }

  dynamic "pages" {
    for_each = var.pages_branch == null ? [] : [null]

    content {
      source {
        branch = var.pages_branch
      }
    }
  }
}

resource "github_actions_repository_permissions" "this" {
  repository      = github_repository.this.name
  allowed_actions = "all"
  enabled         = !var.is_template
}

resource "github_branch_protection" "default_branch" {
  repository_id = github_repository.this.node_id

  pattern        = var.default_branch
  enforce_admins = true
}

data "github_team" "dependabot_reviewers" {
  slug = "dependabot-reviewers"
}

resource "github_team_repository" "dependabot_reviewers" {
  team_id    = data.github_team.dependabot_reviewers.id
  repository = github_repository.this.name
  permission = "maintain"
}
