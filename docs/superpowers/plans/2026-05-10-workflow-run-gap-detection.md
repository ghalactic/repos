# Workflow run gap detection implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a state timeline panel and Grafana alert rules to highlight and
notify on gaps between scheduled workflow runs.

**Architecture:** Restructure threshold inputs from color-based to semantic
(`warning_seconds`, `critical_seconds`). Add a state timeline panel to
`grafana/dashboard.json` using `count_over_time` with threshold-sized Loki range
windows. Add per-workflow Grafana alert rules and a shared "GitHub Actions"
folder for dashboards and alerts. All wired through Terraform `templatefile` and
`replace` patterns.

**Tech Stack:** Terraform (HCL), Grafana dashboard JSON (v2 API), Grafana
Terraform provider (`grafana/grafana ~> 4.0`), Loki LogQL

---

## File map

| File                            | Action | Responsibility                                                                                                                                  |
| ------------------------------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `modules/repo/variables.tf`     | Modify | Replace `last_run_started_thresholds` with `warning_seconds` and `critical_seconds`, add `grafana_folder_uid` and `grafana_loki_datasource_uid` |
| `modules/repo/observability.tf` | Modify | Add threshold color locals, build threshold steps, alert rule, set `folder` on dashboard                                                        |
| `modules/constants/outputs.tf`  | Modify | Remove `grafana_threshold_colors` output                                                                                                        |
| `repos-unique.tf`               | Modify | Update `observe_workflows` blocks to new input shape, pass folder UID and Loki datasource UID to modules                                        |
| `grafana/dashboard.json`        | Modify | Add panel-5 (state timeline), add layout item, shift panel-4 down, add threshold duration placeholders                                          |
| `grafana.tf`                    | Modify | Add `grafana_folder` and `data "grafana_data_source"` for Loki                                                                                  |

---

### Task 1: Restructure threshold inputs

**Files:**

- Modify: `modules/repo/variables.tf:87-97`
- Modify: `modules/constants/outputs.tf:24-31`
- Modify: `repos-unique.tf:33-42,50-59`

- [ ] **Step 1: Update the `observe_workflows` variable definition**

Replace the contents of `modules/repo/variables.tf` lines 87-97 with:

```hcl
variable "observe_workflows" {
  description = "Workflows to observe with Grafana dashboards and OTLP logging. warning_seconds must be less than critical_seconds."
  type = map(object({
    title            = string
    warning_seconds  = number
    critical_seconds = number
  }))
  default = {}
}

variable "grafana_folder_uid" {
  description = "The UID of the Grafana folder for dashboards and alert rules"
  type        = string
  default     = null
}

variable "grafana_loki_datasource_uid" {
  description = "The UID of the Grafana Loki datasource for alert rule queries"
  type        = string
  default     = null
}
```

- [ ] **Step 2: Remove `grafana_threshold_colors` from constants**

Remove lines 24-31 from `modules/constants/outputs.tf` (the
`grafana_threshold_colors` output block):

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

- [ ] **Step 3: Update `repos-unique.tf` to use the new input shape**

Replace the `observe_workflows` block in `module "repo_renovate"` (lines 33-42)
with:

```hcl
  observe_workflows = {
    "renovate.yml" = {
      title            = "Scheduled maintenance runs for ghalactic/renovate"
      warning_seconds  = 5400
      critical_seconds = 7200
    }
  }

  grafana_folder_uid          = grafana_folder.actions.uid
  grafana_loki_datasource_uid = data.grafana_data_source.loki.uid
```

Replace the `observe_workflows` block in `module "repo_token_provider"` (lines
50-59) with:

```hcl
  observe_workflows = {
    "provision-tokens.yml" = {
      title            = "Scheduled token provisioning runs for ghalactic/token-provider"
      warning_seconds  = 2700
      critical_seconds = 3600
    }
  }

  grafana_folder_uid          = grafana_folder.actions.uid
  grafana_loki_datasource_uid = data.grafana_data_source.loki.uid
```

- [ ] **Step 4: Commit**

```bash
git add modules/repo/variables.tf modules/constants/outputs.tf repos-unique.tf
git commit -m "Restructure observe_workflows to semantic thresholds"
```

---

### Task 2: Add threshold color locals and rebuild threshold steps in `observability.tf`

**Files:**

- Modify: `modules/repo/observability.tf:7-19,53-66`

- [ ] **Step 1: Add threshold color locals and threshold step construction**

In `modules/repo/observability.tf`, replace the existing `locals` block (lines
7-19) with:

```hcl
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
```

- [ ] **Step 2: Update the dashboard resource to use the new locals**

Replace the `grafana_dashboard.observed_workflow` resource (lines 53-66) with:

```hcl
resource "grafana_dashboard" "observed_workflow" {
  for_each = var.observe_workflows

  folder = var.grafana_folder_uid

  config_json = replace(
    replace(
      replace(
        templatefile("grafana/dashboard.json", {
          title         = each.value.title
          repo          = var.name
          workflow      = local.workflow_names[each.key]
          workflow_file = each.key
        }),
        "\"__LAST_RUN_STARTED_THRESHOLDS__\"",
        jsonencode(local.last_run_started_thresholds[each.key])
      ),
      "__WARNING_THRESHOLD_SECONDS__",
      tostring(each.value.warning_seconds)
    ),
    "__CRITICAL_THRESHOLD_SECONDS__",
    tostring(each.value.critical_seconds)
  )
}
```

- [ ] **Step 3: Commit**

```bash
git add modules/repo/observability.tf
git commit -m "Add threshold color locals and rebuild threshold steps"
```

---

### Task 3: Add the Grafana folder and Loki datasource lookup

**Files:**

- Modify: `grafana.tf`

- [ ] **Step 1: Add the `grafana_folder` resource and Loki datasource data
      source**

Add the following to `grafana.tf`, after the existing resources:

```hcl
resource "grafana_folder" "actions" {
  title = "GitHub Actions"
}

data "grafana_data_source" "loki" {
  name = "grafanacloud-logs"
}
```

- [ ] **Step 2: Commit**

```bash
git add grafana.tf
git commit -m "Add GitHub Actions Grafana folder and Loki datasource lookup"
```

---

### Task 4: Add the state timeline panel to the dashboard JSON

**Files:**

- Modify: `grafana/dashboard.json`

- [ ] **Step 1: Add the panel-5 element**

In `grafana/dashboard.json`, add a new `"panel-5"` entry inside the `"elements"`
object (after the `"panel-4"` closing `}`). The panel uses two `count_over_time`
queries with placeholder threshold durations:

```json
      "panel-5": {
        "kind": "Panel",
        "spec": {
          "id": 5,
          "title": "Run health",
          "description": "Whether scheduled runs are arriving within the expected intervals",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "loki",
                      "version": "v0",
                      "datasource": {
                        "name": "grafanacloud-logs"
                      },
                      "spec": {
                        "direction": "backward",
                        "editorMode": "code",
                        "expr": "count_over_time({service_name=\"workflow-observability\"} | event=\"workflow_run_created\" | repo=\"${repo}\" | workflow=\"${workflow}\" | trigger=\"schedule\" [__WARNING_THRESHOLD_SECONDS__s])",
                        "queryType": "range",
                        "legendFormat": "warning"
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                },
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "loki",
                      "version": "v0",
                      "datasource": {
                        "name": "grafanacloud-logs"
                      },
                      "spec": {
                        "direction": "backward",
                        "editorMode": "code",
                        "expr": "count_over_time({service_name=\"workflow-observability\"} | event=\"workflow_run_created\" | repo=\"${repo}\" | workflow=\"${workflow}\" | trigger=\"schedule\" [__CRITICAL_THRESHOLD_SECONDS__s])",
                        "queryType": "range",
                        "legendFormat": "critical"
                      }
                    },
                    "refId": "B",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {}
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "state-timeline",
            "version": "13.1.0-25254801320",
            "spec": {
              "options": {
                "showValue": "auto",
                "mergeValues": true,
                "alignValue": "left",
                "legend": {
                  "displayMode": "hidden",
                  "placement": "bottom",
                  "showLegend": false
                },
                "tooltip": {
                  "mode": "single",
                  "sort": "none"
                }
              },
              "fieldConfig": {
                "defaults": {
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "red"
                      },
                      {
                        "value": 1,
                        "color": "green"
                      }
                    ]
                  },
                  "color": {
                    "mode": "thresholds"
                  },
                  "mappings": [
                    {
                      "type": "value",
                      "options": {
                        "0": {
                          "text": "Missing",
                          "color": "red"
                        }
                      }
                    },
                    {
                      "type": "range",
                      "options": {
                        "from": 1,
                        "to": 999999,
                        "result": {
                          "text": "Healthy",
                          "color": "green"
                        }
                      }
                    }
                  ],
                  "custom": {
                    "fillOpacity": 80,
                    "lineWidth": 0
                  }
                },
                "overrides": [
                  {
                    "matcher": {
                      "id": "byName",
                      "options": "warning"
                    },
                    "properties": [
                      {
                        "id": "mappings",
                        "value": [
                          {
                            "type": "value",
                            "options": {
                              "0": {
                                "text": "Delayed",
                                "color": "#EAB839"
                              }
                            }
                          },
                          {
                            "type": "range",
                            "options": {
                              "from": 1,
                              "to": 999999,
                              "result": {
                                "text": "Healthy",
                                "color": "green"
                              }
                            }
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            }
          }
        }
      }
```

- [ ] **Step 2: Add the layout item for panel-5 and shift panel-4 down**

In `grafana/dashboard.json`, in the `"layout"` → `"spec"` → `"items"` array, add
a new layout item for panel-5 before the panel-4 item, and change panel-4's
`"y"` from `8` to `12`:

Add this item after the panel-1 layout item (the one at `x: 18, y: 0`):

```json
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 0,
              "y": 8,
              "width": 24,
              "height": 4,
              "element": {
                "kind": "ElementReference",
                "name": "panel-5"
              }
            }
          },
```

And change panel-4's `"y"` value from `8` to `12`:

```json
              "y": 12,
```

- [ ] **Step 3: Format with prettier**

```bash
npx prettier --write grafana/dashboard.json
```

- [ ] **Step 4: Commit**

```bash
git add grafana/dashboard.json
git commit -m "Add run health state timeline panel to dashboard"
```

---

### Task 5: Add per-workflow Grafana alert rules

**Files:**

- Modify: `modules/repo/observability.tf`

- [ ] **Step 1: Add the `grafana_rule_group` resource**

Add the following resource to `modules/repo/observability.tf`, after the
`grafana_dashboard_public` resource:

```hcl
resource "grafana_rule_group" "observed_workflow" {
  for_each = var.observe_workflows

  name             = "${var.name}/${each.key}"
  folder_uid       = var.grafana_folder_uid
  interval_seconds = 300

  rule {
    name      = "${local.workflow_names[each.key]} in ${var.name}"
    condition = "threshold"

    data {
      ref_id         = "runs"
      datasource_uid = var.grafana_loki_datasource_uid

      relative_time_range {
        from = each.value.critical_seconds
        to   = 0
      }

      model = jsonencode({
        expr      = "count_over_time({service_name=\"workflow-observability\"} | event=\"workflow_run_created\" | repo=\"${var.name}\" | workflow=\"${local.workflow_names[each.key]}\" | trigger=\"schedule\" [${each.value.critical_seconds}s])"
        queryType = "range"
        refId     = "runs"
      })
    }

    data {
      ref_id         = "threshold"
      datasource_uid = "__expr__"

      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        type       = "threshold"
        expression = "runs"
        refId      = "threshold"
        conditions = [
          {
            type = "query"
            evaluator = {
              type   = "lt"
              params = [1]
            }
          }
        ]
      })
    }

    labels = {
      repo     = var.name
      workflow = local.workflow_names[each.key]
    }

    annotations = {
      summary = "No scheduled run of ${local.workflow_names[each.key]} in ${var.name} for over ${each.value.critical_seconds} seconds"
    }

    for = "0s"
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add modules/repo/observability.tf
git commit -m "Add per-workflow Grafana alert rules"
```

---

### Task 6: Format and validate

- [ ] **Step 1: Format all Terraform files**

```bash
terraform fmt -recursive
```

- [ ] **Step 2: Format dashboard JSON with prettier**

```bash
npx prettier --write grafana/dashboard.json
```

- [ ] **Step 3: Validate Terraform configuration**

```bash
terraform validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 4: Commit any formatting changes**

```bash
git add -A
git commit -m "Format Terraform and JSON files" --allow-empty
```

---

### Task 7: Review the Terraform plan

- [ ] **Step 1: Run `terraform plan`**

```bash
terraform plan
```

Review the output. Expected changes:

- `modules/constants/outputs.tf`: `grafana_threshold_colors` output removed
- `grafana_folder.actions`: created (1 new resource in root module)
- `grafana_dashboard.observed_workflow` (in each repo module): updated in-place
  (new `folder` attribute, new panel in config JSON, threshold placeholders
  replaced)
- `grafana_rule_group.observed_workflow` (in each repo module): created (1 per
  observed workflow)
- No unexpected destroys or recreations

- [ ] **Step 2: Verify the generated dashboard JSON**

Spot-check one of the generated dashboard configs in the plan output to confirm:

- `__WARNING_THRESHOLD_SECONDS__` and `__CRITICAL_THRESHOLD_SECONDS__` are
  replaced with actual numbers (e.g., `5400` and `7200`)
- `__LAST_RUN_STARTED_THRESHOLDS__` is replaced with the threshold steps array
- panel-5 exists with the state timeline visualization
- panel-4 is at `y: 12`
