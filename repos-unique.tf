module "repo_branding" {
  source       = "./modules/repo"
  name         = "branding"
  description  = "Branding assets for Ghalactic"
  homepage_url = "https://ghalactic.github.io/branding"

  pages_branch = "gh-pages"

  has_publish_release_workflow = false
  dependabot_ecosystems        = ["github-actions", "npm"]
}

module "repo_org_dot_github_dot_io" {
  source       = "./modules/repo"
  name         = "ghalactic.github.io"
  description  = "The Ghalactic website"
  homepage_url = "https://ghalactic.github.io"

  pages_branch = "main"

  has_publish_release_workflow = false
}
