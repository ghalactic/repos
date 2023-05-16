resource "github_repository_file" "dot_github_workflows_ci_scheduled_yml" {
  for_each = toset(var.ci_workflows)

  commit_author       = module.constants.committer.name
  commit_email        = module.constants.committer.email
  repository          = github_repository.this.name
  branch              = data.github_repository.this.default_branch
  file                = ".github/workflows/ci-${each.value}-scheduled.yml"
  commit_message      = "Update \"CI (scheduled)\" GHA workflow"
  overwrite_on_create = true

  content = templatefile("dot-github/workflows/ci-${each.value}-scheduled.yml", {
    org      = module.constants.org
    org_name = module.constants.org_name
  })
}

resource "github_repository_file" "dot_github_workflows_ci_yml" {
  for_each = toset(var.ci_workflows)

  commit_author       = module.constants.committer.name
  commit_email        = module.constants.committer.email
  repository          = github_repository.this.name
  branch              = data.github_repository.this.default_branch
  file                = ".github/workflows/ci-${each.value}.yml"
  commit_message      = "Update \"CI\" GHA workflow"
  overwrite_on_create = true

  content = templatefile("dot-github/workflows/ci-${each.value}.yml", {
    org      = module.constants.org
    org_name = module.constants.org_name
  })
}

resource "github_repository_file" "dot_github_workflows_publish_release_yml" {
  for_each = toset(var.publish_release_workflow ? ["basic"] : [])

  commit_author       = module.constants.committer.name
  commit_email        = module.constants.committer.email
  repository          = github_repository.this.name
  branch              = data.github_repository.this.default_branch
  file                = ".github/workflows/publish-release.yml"
  commit_message      = "Update \"Publish release\" GHA workflow"
  overwrite_on_create = true

  content = templatefile("dot-github/workflows/publish-release.yml", {
    org      = module.constants.org
    org_name = module.constants.org_name
  })
}
