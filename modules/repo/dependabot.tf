resource "github_repository_file" "dot_github_dependabot_yml" {
  count = 1

  commit_author       = module.constants.committer.name
  commit_email        = module.constants.committer.email
  repository          = github_repository.this.name
  branch              = data.github_repository.this.default_branch
  file                = ".github/dependabot.yml"
  commit_message      = "Update Dependabot configuration"
  overwrite_on_create = true

  content = templatefile("dot-github/dependabot.yml", {
    ecosystems = var.dependabot_ecosystems
    org        = module.constants.org
  })
}
