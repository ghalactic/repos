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

  pages_branch = "gh-pages"

  use_release_action_main       = true
  renovate_post_upgrade_command = "make regenerate"

  has_discussions = true
}

module "repo_provision_github_tokens" {
  source      = "./modules/repo"
  name        = "provision-github-tokens"
  description = "A GitHub Action that creates and rotates GitHub tokens for you"
  template    = { owner = "ghalactic", repository = "action-template" }

  topics = [
    "actions",
    "github-actions",
    "security",
    "devops",
    "infrastructure-as-code",
    "provisioning",
    "automation",
  ]

  pages_branch = "gh-pages"

  renovate_post_upgrade_command = "make regenerate"
}
