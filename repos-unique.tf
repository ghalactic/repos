module "repo_branding" {
  source       = "./modules/repo"
  name         = "branding"
  description  = "Branding assets for Ghalactic"
  homepage_url = "https://ghalactic.github.io/branding"

  pages_branch = "gh-pages"

  publish_release_workflow = false
  dependabot_ecosystems    = ["github-actions", "npm"]
}
