module "repo_action_template" {
  source      = "./modules/repo"
  name        = "action-template"
  description = "A template repo for creating GitHub Actions"

  ci_workflows          = ["node"]
  dependabot_ecosystems = ["github-actions", "npm"]

  is_template = true
}
