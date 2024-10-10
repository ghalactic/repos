module "repo_action_template" {
  source      = "./modules/repo"
  name        = "action-template"
  description = "A template repo for creating GitHub Actions"

  renovate_post_upgrade_command = "make regenerate"

  is_template = true
}
