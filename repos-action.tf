module "repo_github_release_from_tag" {
  source       = "./modules/repo"
  name         = "github-release-from-tag"
  description  = "A GitHub Action that creates GitHub Releases from your Git tags"
  homepage_url = "https://github.com/marketplace/actions/github-release-from-tag"

  topics = [
    "actions",
    "github-actions",
    "publishing",
    "release",
    "release-automation",
  ]

  ci_workflows           = ["action"]
  dependabot_ecosystems  = ["github-actions", "npm"]
  release_action_version = "main"

  has_discussions         = true
  has_release_discussions = true
}

module "repo_dependabot_automation" {
  source       = "./modules/repo"
  name         = "dependabot-automation"
  description  = "A GitHub Action that automates your Dependabot busywork"
  homepage_url = "https://github.com/marketplace/actions/dependabot-automation"

  topics = [
    "actions",
    "github-actions",
    "dependabot",
    "automation",
  ]

  ci_workflows          = ["action"]
  dependabot_ecosystems = ["github-actions", "npm"]

  has_discussions = true

  template = {
    owner      = module.constants.org
    repository = module.repo_action_template.name
  }
}
