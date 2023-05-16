module "repo_branding" {
  source      = "./modules/repo"
  name        = "branding"
  description = "Branding assets for Ghalactic"

  dependabot_ecosystems = ["github-actions", "npm"]
}
