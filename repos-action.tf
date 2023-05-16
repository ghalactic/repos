module "repo_github_credential_rotation_action" {
  source      = "./modules/repo"
  name        = "github-credential-rotation-action"
  description = "A GitHub Action that rotates GitHub tokens for you"

  ci_workflows          = ["node"]
  dependabot_ecosystems = ["docker", "github-actions", "npm"]
}
