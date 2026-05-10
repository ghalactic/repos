# Workflow Observability Terraform Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Codify the workflow observability system (Grafana Cloud stack,
credentials, dashboards, GitHub Actions observer workflows) as Terraform
configuration in ghalactic/repos.

**Architecture:** Top-level `grafana.tf` manages the Grafana Cloud stack, access
policy, token, and GitHub org credentials. Per-repo observability is opt-in via
`observe_workflows` on the repo module, which generates observer workflow files
and Grafana dashboards.

**Tech Stack:** Terraform, `integrations/github` provider, `grafana/grafana`
provider, Grafana Cloud, GitHub Actions

**Worktree:** `/Users/erin/worktrees/github.com/ghalactic/repos/observability`

**Spec:**
`docs/superpowers/specs/2026-05-10-workflow-observability-terraform-design.md`

---

## File map

| File                                      | Action | Purpose                                        |
| ----------------------------------------- | ------ | ---------------------------------------------- |
| `provider.tf`                             | Modify | Add `grafana/grafana` provider                 |
| `variables.tf`                            | Modify | Add Grafana Cloud API key variable             |
| `grafana.tf`                              | Create | Stack, access policy, token, org vars/secret   |
| `modules/constants/outputs.tf`            | Modify | Add `grafana_threshold_colors` output          |
| `modules/repo/variables.tf`               | Modify | Add `observe_workflows` variable               |
| `modules/repo/observability.tf`           | Create | Workflow name lookup, file gen, dashboards     |
| `dot-github/observe-workflow-runs.yml`    | Create | Template for run observer workflow             |
| `dot-github/observe-workflow-changes.yml` | Create | Template for change observer workflow          |
| `grafana/dashboard.json`                  | Create | Templatized dashboard JSON                     |
| `repos-template.tf`                       | Modify | Add `observe_workflows` to renovate/token-prov |

## Existing resources to import

The user will add `import` blocks for these existing resources:

**Top-level (grafana.tf):**

- `grafana_cloud_stack.this` — the existing `ghalactic` stack
- `github_actions_organization_variable.otlp_endpoint` — `OTLP_ENDPOINT`
- `github_actions_organization_variable.otlp_username` — `OTLP_USERNAME`
- `github_actions_organization_secret.otlp_password` — `OTLP_PASSWORD`

**Per-repo (modules/repo/observability.tf):**

- `github_repository_file.observe_workflow_runs` for
  `.github/workflows/observe-workflow-runs.yml` in token-provider and renovate
- `github_repository_file.observe_workflow_changes` for
  `.github/workflows/observe-workflow-changes.yml` in token-provider and
  renovate

The access policy and token are new (replacing the manually created ones), so no
import is needed for those.

---

### Task 1: Add Grafana provider

**Files:**

- Modify: `provider.tf`
- Modify: `variables.tf`

- [ ] **Step 1: Add the Grafana provider to `provider.tf`**

Add the Grafana provider requirement and configuration after the existing GitHub
provider:

```hcl
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.0"
    }
  }
}

provider "github" {
  owner = module.constants.org

  app_auth {
    id              = var.GITHUB_APP_ID
    installation_id = var.GITHUB_APP_INSTALLATION_ID
    pem_file        = var.GITHUB_APP_PEM_FILE
  }
}

provider "grafana" {
  cloud_access_policy_token = var.GRAFANA_CLOUD_API_KEY
}
```

- [ ] **Step 2: Add the Grafana Cloud API key variable to `variables.tf`**

Append to the existing variables:

```hcl
variable "GRAFANA_CLOUD_API_KEY" {
  type      = string
  sensitive = true
}
```

- [ ] **Step 3: Run `terraform init` to install the Grafana provider**

Run: `terraform init -upgrade`

Expected: Provider `grafana/grafana` is installed, lock file updated.

- [ ] **Step 4: Commit**

```bash
git add provider.tf variables.tf .terraform.lock.hcl
git commit -m "Add Grafana provider"
```

---

### Task 2: Add Grafana threshold colors to constants module

**Files:**

- Modify: `modules/constants/outputs.tf`

- [ ] **Step 1: Add `grafana_threshold_colors` output**

Append after the existing `org_name` output (before the `locals` block):

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

- [ ] **Step 2: Run `terraform validate`**

Run: `terraform validate`

Expected: `Success! The configuration is valid.`

- [ ] **Step 3: Commit**

```bash
git add modules/constants/outputs.tf
git commit -m "Add Grafana threshold colors to constants"
```

---

### Task 3: Create top-level Grafana resources

**Files:**

- Create: `grafana.tf`

- [ ] **Step 1: Create `grafana.tf` with stack, access policy, token, and org
      credentials**

```hcl
resource "grafana_cloud_stack" "this" {
  name        = "ghalactic"
  slug        = "ghalactic"
  region_slug = "prod-us-east-3"
}

resource "grafana_cloud_access_policy" "workflow_observability" {
  name         = "workflow-observability"
  display_name = "Workflow observability"
  region       = grafana_cloud_stack.this.region_slug

  scopes = ["logs:write", "metrics:write"]

  realm {
    type       = "stack"
    identifier = grafana_cloud_stack.this.id
  }
}

resource "grafana_cloud_access_policy_token" "workflow_observability" {
  name             = "github-actions-workflows"
  access_policy_id = grafana_cloud_access_policy.workflow_observability.policy_id
  region           = grafana_cloud_stack.this.region_slug
}

resource "github_actions_organization_variable" "otlp_endpoint" {
  variable_name = "OTLP_ENDPOINT"
  value         = "https://otlp-gateway-${grafana_cloud_stack.this.region_slug}.grafana.net/otlp"
  visibility    = "all"
}

resource "github_actions_organization_variable" "otlp_username" {
  variable_name = "OTLP_USERNAME"
  value         = grafana_cloud_stack.this.id
  visibility    = "all"
}

resource "github_actions_organization_secret" "otlp_password" {
  secret_name     = "OTLP_PASSWORD"
  plaintext_value = grafana_cloud_access_policy_token.workflow_observability.token
  visibility      = "all"
}
```

- [ ] **Step 2: Run `terraform validate`**

Run: `terraform validate`

Expected: `Success! The configuration is valid.`

- [ ] **Step 3: Commit**

```bash
git add grafana.tf
git commit -m "Add top-level Grafana Cloud resources"
```

---

### Task 4: Create observer workflow templates

**Files:**

- Create: `dot-github/observe-workflow-runs.yml`
- Create: `dot-github/observe-workflow-changes.yml`

- [ ] **Step 1: Create the run observer template**

Create `dot-github/observe-workflow-runs.yml`:

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

- [ ] **Step 2: Create the change observer template**

Create `dot-github/observe-workflow-changes.yml`:

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

- [ ] **Step 3: Commit**

```bash
git add dot-github/observe-workflow-runs.yml dot-github/observe-workflow-changes.yml
git commit -m "Add observer workflow templates"
```

---

### Task 5: Create the dashboard JSON template

**Files:**

- Create: `grafana/dashboard.json`

- [ ] **Step 1: Create the `grafana` directory and templatized dashboard JSON**

Take the exported dashboard JSON from
`/Users/erin/Downloads/dashboard-1778362553377.json` (token-provider dashboard)
and create a templatized version at `grafana/dashboard.json`.

Strip from the export:

- The `apiVersion`, `kind`, and `metadata` wrapper — the `grafana_dashboard`
  resource only needs the inner dashboard model, not the Grafana API envelope
- `timeSettings.timezone` — let it default to browser timezone

Replace with template variables:

- All occurrences of `token-provider` → `${repo}`
- All occurrences of `Provision tokens` → `${workflow}`
- All occurrences of `.github/workflows/provision-tokens.yml` →
  `.github/workflows/${workflow_file}`
- The dashboard `title` field → `${title}`
- The `thresholds.steps` array in the "Last run started" panel (panel-1) →
  `${last_run_started_thresholds}`

The `last_run_started_thresholds` substitution replaces the full JSON array, so
use it directly without quotes:

```json
"steps": ${last_run_started_thresholds}
```

The caller passes `jsonencode()` of the thresholds list.

Important: the `grafana_dashboard` resource expects a `config_json` string
containing the dashboard model JSON. Check the Grafana Terraform provider docs
for the exact expected format — the exported JSON uses a `v2` API schema that
may differ from what `config_json` expects. The provider may need the classic
dashboard JSON format (with `panels` array, not the newer `elements` map with
`GridLayout`). If so, export the dashboard using the "Share → Export → Export
for sharing externally" option in the Grafana UI to get the classic format.

- [ ] **Step 2: Verify the template**

Check that:

- No hardcoded `token-provider`, `Provision tokens`, or `provision-tokens.yml`
  remain
- All `${...}` variables match: `title`, `repo`, `workflow`, `workflow_file`,
  `last_run_started_thresholds`
- The JSON structure is valid (apart from the `${...}` interpolations)

- [ ] **Step 3: Commit**

```bash
git add grafana/dashboard.json
git commit -m "Add templatized Grafana dashboard"
```

---

### Task 6: Add `observe_workflows` variable to the repo module

**Files:**

- Modify: `modules/repo/variables.tf`

- [ ] **Step 1: Add the variable definition**

Append to the end of `modules/repo/variables.tf`:

```hcl
variable "observe_workflows" {
  description = "Workflows to observe with Grafana dashboards and OTLP logging"
  type = map(object({
    title = string
    last_run_started_thresholds = list(object({
      value = number
      color = string
    }))
  }))
  default = {}
}
```

- [ ] **Step 2: Run `terraform validate`**

Run: `terraform validate`

Expected: `Success! The configuration is valid.`

- [ ] **Step 3: Commit**

```bash
git add modules/repo/variables.tf
git commit -m "Add observe_workflows variable to repo module"
```

---

### Task 7: Create `observability.tf` in the repo module

**Files:**

- Create: `modules/repo/observability.tf`

- [ ] **Step 1: Create the file with workflow name lookup, observer file
      generation, and dashboard creation**

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

  observed_workflow_files = [
    for file, _ in var.observe_workflows :
    ".github/workflows/${file}"
  ]
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
  })
}

resource "grafana_dashboard" "observed_workflow" {
  for_each = var.observe_workflows

  config_json = templatefile("grafana/dashboard.json", {
    title                       = each.value.title
    repo                        = var.name
    workflow                    = local.workflow_names[each.key]
    workflow_file               = ".github/workflows/${each.key}"
    last_run_started_thresholds = jsonencode(each.value.last_run_started_thresholds)
  })
}
```

- [ ] **Step 2: Run `terraform validate`**

Run: `terraform validate`

Expected: `Success! The configuration is valid.`

- [ ] **Step 3: Commit**

```bash
git add modules/repo/observability.tf
git commit -m "Add observability.tf to repo module"
```

---

### Task 8: Wire up `observe_workflows` for token-provider and renovate

**Files:**

- Modify: `repos-template.tf`

- [ ] **Step 1: Add `observe_workflows` to the token-provider module call**

Update `module "repo_token_provider"` in `repos-template.tf`:

```hcl
module "repo_token_provider" {
  source      = "./modules/repo"
  name        = "token-provider"
  description = "Provisions GitHub tokens for Ghalactic"

  observe_workflows = {
    "provision-tokens.yml" = {
      title = "Scheduled token provisioning runs for ghalactic/token-provider"
      last_run_started_thresholds = [
        { value = 0, color = module.constants.grafana_threshold_colors.green },
        { value = 2700, color = module.constants.grafana_threshold_colors.yellow },
        { value = 3600, color = module.constants.grafana_threshold_colors.red },
      ]
    }
  }
}
```

- [ ] **Step 2: Add `observe_workflows` to the renovate module call**

Update `module "repo_renovate"` in `repos-template.tf`:

```hcl
module "repo_renovate" {
  source       = "./modules/repo"
  name         = "renovate"
  description  = "Self-hosted Renovate for Ghalactic"
  homepage_url = "https://github.com/ghalactic/renovate/actions/workflows/renovate.yml"

  manage_renovate = false

  observe_workflows = {
    "renovate.yml" = {
      title = "Scheduled maintenance runs for ghalactic/renovate"
      last_run_started_thresholds = [
        { value = 0, color = module.constants.grafana_threshold_colors.green },
        { value = 5400, color = module.constants.grafana_threshold_colors.yellow },
        { value = 7200, color = module.constants.grafana_threshold_colors.red },
      ]
    }
  }
}
```

- [ ] **Step 3: Run `terraform validate`**

Run: `terraform validate`

Expected: `Success! The configuration is valid.`

- [ ] **Step 4: Commit**

```bash
git add repos-template.tf
git commit -m "Enable workflow observability for token-provider and renovate"
```

---

### Task 9: Format and validate the full configuration

- [ ] **Step 1: Run `terraform fmt -recursive`**

Run: `terraform fmt -recursive`

Expected: Lists any files that were reformatted, or no output if already
formatted.

- [ ] **Step 2: Run `terraform validate`**

Run: `terraform validate`

Expected: `Success! The configuration is valid.`

- [ ] **Step 3: Run Prettier on Markdown files**

Run: `npx prettier --write "**/*.md"`

- [ ] **Step 4: Commit any formatting changes**

```bash
git add -A
git commit -m "Format Terraform and Markdown files"
```
