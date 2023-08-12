module "repo_action_template" {
  source      = "./modules/repo"
  name        = "action-template"
  description = "A template repo for creating GitHub Actions"

  ci_workflows                  = ["action"]
  renovate_post_upgrade_command = "npm run renovate-post-update"

  is_template = true
}
