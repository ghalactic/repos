resource "github_repository_file" "dot_github_workflows_ci_yml" {
  for_each = toset(var.ci_workflows)

  commit_author       = module.constants.committer.name
  commit_email        = module.constants.committer.email
  repository          = github_repository.this.name
  file                = ".github/workflows/ci-${each.value}.yml"
  commit_message      = "Update \"CI\" GHA workflow"
  overwrite_on_create = true

  content = templatefile("dot-github/workflows/ci.yml", {
    ci_type  = each.value
    org      = module.constants.org
    org_name = module.constants.org_name
  })
}

resource "github_repository_file" "dot_github_workflows_ci_scheduled_yml" {
  for_each = toset(var.ci_workflows)

  commit_author       = module.constants.committer.name
  commit_email        = module.constants.committer.email
  repository          = github_repository.this.name
  file                = ".github/workflows/ci-${each.value}-scheduled.yml"
  commit_message      = "Update \"CI (scheduled)\" GHA workflow"
  overwrite_on_create = true

  content = templatefile("dot-github/workflows/ci-scheduled.yml", {
    ci_type  = each.value
    org      = module.constants.org
    org_name = module.constants.org_name
  })
}

resource "github_repository_file" "dot_github_workflows_publish_release_yml" {
  for_each = toset(var.has_publish_release_workflow ? ["basic"] : [])

  commit_author       = module.constants.committer.name
  commit_email        = module.constants.committer.email
  repository          = github_repository.this.name
  file                = ".github/workflows/publish-release.yml"
  commit_message      = "Update \"Publish release\" GHA workflow"
  overwrite_on_create = true

  content = templatefile("dot-github/workflows/publish-release.yml", {
    discussion_category    = var.has_release_discussions ? "Releases" : ""
    make_target            = var.release_make_target == null ? "" : var.release_make_target
    org                    = module.constants.org
    org_name               = module.constants.org_name
    release_action_version = var.release_action_version == null ? "" : var.release_action_version
  })
}

resource "github_repository_file" "dot_github_workflows_publish_release_manual_yml" {
  for_each = toset(var.has_publish_release_workflow ? ["basic"] : [])

  commit_author       = module.constants.committer.name
  commit_email        = module.constants.committer.email
  repository          = github_repository.this.name
  file                = ".github/workflows/publish-release-manual.yml"
  commit_message      = "Update \"Publish release (manual)\" GHA workflow"
  overwrite_on_create = true

  content = templatefile("dot-github/workflows/publish-release-manual.yml", {
    discussion_category    = var.has_release_discussions ? "Releases" : ""
    make_target            = var.release_make_target == null ? "" : var.release_make_target
    org                    = module.constants.org
    org_name               = module.constants.org_name
    release_action_version = var.release_action_version == null ? "" : var.release_action_version
  })
}
