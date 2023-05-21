module "repo_github_credential_rotation_action" {
  source      = "./modules/repo"
  name        = "github-credential-rotation-action"
  description = "A GitHub Action that rotates GitHub tokens for you"

  ci_workflows          = ["node"]
  dependabot_ecosystems = ["docker", "github-actions", "npm"]
}

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

  ci_workflows             = []
  publish_release_workflow = false
  dependabot_ecosystems    = ["github-actions", "npm"]
}
