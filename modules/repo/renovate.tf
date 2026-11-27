locals {
  renovate_post_upgrade_uses_mise = (
    var.renovate_post_upgrade_command == null
    ? false
    : startswith(var.renovate_post_upgrade_command, "mise ")
  )
}

resource "github_repository_file" "dot_github_renovate_json" {
  count = var.manage_renovate ? 1 : 0

  commit_author       = module.constants.committer.name
  commit_email        = module.constants.committer.email
  repository          = github_repository.this.name
  file                = ".github/renovate.json"
  commit_message      = "Update Renovate configuration"
  overwrite_on_create = true

  content = templatefile("dot-github/renovate.json", {
    post_upgrade_command   = var.renovate_post_upgrade_command
    post_upgrade_uses_mise = local.renovate_post_upgrade_uses_mise
    org                    = module.constants.org
  })
}
