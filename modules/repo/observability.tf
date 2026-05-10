data "github_repository_file" "observed_workflow" {
  for_each   = var.observe_workflows
  repository = var.name
  file       = ".github/workflows/${each.key}"
}

locals {
  threshold_colors = {
    healthy  = "green"
    warning  = "#EAB839"
    critical = "red"
  }

  workflow_names = {
    for file, config in var.observe_workflows :
    file => yamldecode(
      data.github_repository_file.observed_workflow[file].content
    ).name
  }

  observed_workflow_files = [
    for file, _ in var.observe_workflows :
    ".github/workflows/${file}"
  ]

  last_run_started_thresholds = {
    for file, config in var.observe_workflows : file => [
      { value = 0, color = local.threshold_colors.healthy },
      { value = config.warning_seconds, color = local.threshold_colors.warning },
      { value = config.critical_seconds, color = local.threshold_colors.critical },
    ]
  }
}

resource "github_repository_file" "observe_workflow_runs" {
  count = length(var.observe_workflows) > 0 ? 1 : 0

  commit_author       = module.constants.committer.name
  commit_email        = module.constants.committer.email
  repository          = github_repository.this.name
  file                = ".github/workflows/observe-workflow-runs.yml"
  commit_message      = "Update workflow run observer"
  overwrite_on_create = true

  content = templatefile("dot-github/observe-workflow-runs.yml", {
    workflows_json = jsonencode(values(local.workflow_names))
    org            = module.constants.org
  })
}

resource "github_repository_file" "observe_workflow_changes" {
  count = length(var.observe_workflows) > 0 ? 1 : 0

  commit_author       = module.constants.committer.name
  commit_email        = module.constants.committer.email
  repository          = github_repository.this.name
  file                = ".github/workflows/observe-workflow-changes.yml"
  commit_message      = "Update workflow change observer"
  overwrite_on_create = true

  content = templatefile("dot-github/observe-workflow-changes.yml", {
    paths_json = jsonencode(local.observed_workflow_files)
    org        = module.constants.org
  })
}

resource "grafana_dashboard" "observed_workflow" {
  for_each = var.observe_workflows

  folder = var.grafana_folder_uid

  config_json = replace(
    templatefile("grafana/dashboard.json", {
      dashboard_uid = "gha-${var.name}-${replace(each.key, ".", "-")}"
      title         = each.value.title
      repo          = var.name
      workflow      = local.workflow_names[each.key]
      workflow_file = each.key
    }),
    "\"__LAST_RUN_STARTED_THRESHOLDS__\"",
    jsonencode(local.last_run_started_thresholds[each.key])
  )
}

resource "grafana_dashboard_public" "observed_workflow" {
  for_each = var.observe_workflows

  dashboard_uid = grafana_dashboard.observed_workflow[each.key].uid

  annotations_enabled    = true
  is_enabled             = true
  time_selection_enabled = true
}

output "workflow_dashboard_public_urls" {
  description = "A map of observed workflow names to their public Grafana dashboard URLs."
  value = {
    for file, config in var.observe_workflows :
    file => format(
      "%s/public-dashboards/%s",
      join("/", slice(split("/", grafana_dashboard.observed_workflow[file].url), 0, 3)),
      grafana_dashboard_public.observed_workflow[file].access_token
    )
  }
}
