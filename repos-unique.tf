module "repo_branding" {
  source      = "./modules/repo"
  name        = "branding"
  description = "Branding assets for Ghalactic"

  publish_release_workflow = false
  dependabot_ecosystems    = ["github-actions", "npm"]
}
