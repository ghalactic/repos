# Workflow Observability Terraform Module

Codify the existing workflow observability system (OTLP logs to Grafana Cloud,
dashboards, GitHub Actions observer workflows) as Terraform configuration within
the ghalactic/repos repository.

## Goals

- Manage Grafana Cloud resources (stack, access policy, token) via Terraform
- Push OTLP credentials to GitHub org variables/secrets via Terraform
- Generate per-repo observer workflow files when observability is enabled
- Generate per-workflow Grafana dashboards from a shared template
- Follow existing patterns in the repo (module structure, file conventions,
  constants module)

## Architecture

### Two layers

1. **Top-level Grafana Cloud resources** — configured once for the whole org
2. **Per-repo integration** — opt-in via the existing `repo` module's variables

### Top-level resources

New files at the repo root:

- **`grafana.tf`** — manages:
  - `grafana_cloud_stack` resource (import existing stack)
  - `grafana_cloud_access_policy` with `logs:write` and `metrics:write` scopes
  - `grafana_cloud_access_policy_token`
  - `github_actions_organization_variable` for `OTLP_ENDPOINT` and
    `OTLP_USERNAME`
  - `github_actions_organization_secret` for `OTLP_PASSWORD` (set to the
    generated token)

Provider configuration additions to `provider.tf`:

- Add `grafana/grafana` provider
- New Terraform Cloud variable: Grafana Cloud API key for provider auth

The Grafana Cloud org itself cannot be managed via Terraform and remains manual.

### Per-repo integration

New file in the repo module: **`modules/repo/observability.tf`**

When `observe_workflows` is non-empty, this file:

1. Reads each workflow file via `data "github_repository_file"` and extracts the
   workflow display name using `yamldecode()`
2. Commits two observer workflow files to the repo via `github_repository_file`:
   - `.github/workflows/observe-workflow-runs.yml` — combined `workflow_run`
     triggers for all observed workflow names
   - `.github/workflows/observe-workflow-changes.yml` — combined `push` path
     triggers for all observed workflow files
3. Creates a `grafana_dashboard` resource per observed workflow from a
   templatized JSON template

When `observe_workflows` is empty (default), no observer files or dashboards are
created.

## Variable shape

The `observe_workflows` variable is a map keyed by workflow file path:

```hcl
variable "observe_workflows" {
  description = "Workflows to observe with Grafana dashboards and OTLP logging"
  type = map(object({
    title                       = string
    last_run_started_thresholds = list(object({
      value = number
      color = string
    }))
  }))
  default = {}
}
```

### Usage example

```hcl
module "repo_token_provider" {
  source      = "./modules/repo"
  name        = "token-provider"
  description = "Provisions GitHub tokens for Ghalactic"

  observe_workflows = {
    "provision-tokens.yml" = {
      title = "Scheduled token provisioning runs for ghalactic/token-provider"
      last_run_started_thresholds = [
        { value = 0,    color = module.constants.grafana_threshold_colors.green },
        { value = 2700, color = module.constants.grafana_threshold_colors.yellow },
        { value = 3600, color = module.constants.grafana_threshold_colors.red },
      ]
    }
  }
}

module "repo_renovate" {
  source       = "./modules/repo"
  name         = "renovate"
  description  = "Self-hosted Renovate for Ghalactic"

  observe_workflows = {
    "renovate.yml" = {
      title = "Scheduled maintenance runs for ghalactic/renovate"
      last_run_started_thresholds = [
        { value = 0,    color = module.constants.grafana_threshold_colors.green },
        { value = 5400, color = module.constants.grafana_threshold_colors.yellow },
        { value = 7200, color = module.constants.grafana_threshold_colors.red },
      ]
    }
  }
}
```

## Constants module additions

New output in `modules/constants/outputs.tf`:

```hcl
output "grafana_threshold_colors" {
  description = "Standard threshold colors for Grafana dashboards"
  value = {
    green  = "green"
    yellow = "#EAB839"
    red    = "red"
  }
}
```

## File locations

| File                                      | Purpose                                      |
| ----------------------------------------- | -------------------------------------------- |
| `provider.tf`                             | Add Grafana provider config                  |
| `grafana.tf`                              | Stack, access policy, token, org vars/secret |
| `modules/repo/observability.tf`           | Per-repo observer workflows + dashboards     |
| `modules/repo/variables.tf`               | Add `observe_workflows` variable             |
| `modules/constants/outputs.tf`            | Add `grafana_threshold_colors`               |
| `dot-github/observe-workflow-runs.yml`    | Template for run observer workflow           |
| `dot-github/observe-workflow-changes.yml` | Template for change observer workflow        |
| `grafana/dashboard.json`                  | Templatized dashboard JSON                   |

## Templates

### Observer workflow templates

Located in `dot-github/`, these are Terraform `templatefile()` sources committed
to each repo via `github_repository_file`.

**`dot-github/observe-workflow-runs.yml`** — receives a list of workflow display
names:

```yaml
name: Observe workflow runs

on:
  workflow_run:
    workflows: ${workflows_json}
    types: [requested, completed]

jobs:
  report:
    name: Ghalactic
    uses: ghalactic/repos/.github/workflows/shared-observe-workflow-runs.yml@main
    secrets: inherit
```

**`dot-github/observe-workflow-changes.yml`** — receives a list of workflow file
paths:

```yaml
name: Observe workflow changes

on:
  push:
    paths: ${paths_json}
    branches: [main]

jobs:
  report:
    name: Ghalactic
    uses: ghalactic/repos/.github/workflows/shared-observe-workflow-changes.yml@main
    secrets: inherit
```

### Dashboard template

Located in `grafana/dashboard.json`, this is a templatized version of the
exported dashboard JSON with substitution variables for:

- `title` — dashboard title (static string from config)
- `repo` — repository name
- `workflow` — workflow display name (looked up via API)
- `workflow_file` — workflow file path (for annotation filtering)
- `last_run_started_thresholds` — JSON-encoded threshold steps array

The template is derived from the current exported dashboards, stripped of:

- Grafana metadata (uid, resourceVersion, generation, timestamps)
- Timezone setting (defaults to browser timezone)
- Stack-specific namespace references

The Loki data source name (`grafanacloud-logs`) is hardcoded in the template
since it's a standard Grafana Cloud convention.

## Workflow name lookup

Each observed workflow's display name is resolved at plan/apply time:

```hcl
data "github_repository_file" "observed_workflow" {
  for_each   = var.observe_workflows
  repository = var.name
  file       = ".github/workflows/${each.key}"
}

locals {
  workflow_names = {
    for file, config in var.observe_workflows :
    file => yamldecode(
      data.github_repository_file.observed_workflow[file].content
    ).name
  }
}
```

The workflow file must already exist in the repo before Terraform runs. This is
always true since these are the "real" workflows being observed, not the
observer workflows we generate.

## What is NOT managed by Terraform

- The Grafana Cloud organization (not supported by the provider)
- The actual workflow files being observed (e.g. `provision-tokens.yml`)
- The shared reusable workflows in `repos/.github/workflows/shared-observe-*`
- Dashboard content changes made in the Grafana UI (will be overwritten on next
  apply)

## Credential flow

1. Terraform creates a Cloud Access Policy + token in Grafana Cloud
2. Terraform pushes the token to `OTLP_PASSWORD` GitHub org secret
3. Terraform sets `OTLP_ENDPOINT` and `OTLP_USERNAME` as GitHub org variables
4. Observer workflows (generated by Terraform) use these credentials to push
   OTLP logs
5. Dashboards (generated by Terraform) query these logs from the Loki data
   source

## Existing credentials to clean up

After Terraform manages credentials, these manually created org-level
secrets/variables should be removed:

- `GRAFANA_METRICS_INFLUX_EP` (variable)
- `GRAFANA_METRICS_AP_ID` (variable)
- `GRAFANA_METRICS_AP_TOKEN` (secret)
- `OTLP_TOKEN` (secret)

These can be imported into Terraform as resources and then removed, or deleted
manually.
