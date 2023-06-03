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
