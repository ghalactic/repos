module "repo_branding" {
  source       = "./modules/repo"
  name         = "branding"
  description  = "Branding assets for Ghalactic"
  homepage_url = "https://ghalactic.github.io/branding"

  pages_branch = "gh-pages"
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
}
