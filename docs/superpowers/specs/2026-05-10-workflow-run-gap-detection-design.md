# Workflow run gap detection

## Problem

The current observability setup tracks scheduled workflow run frequency,
duration, and staleness. The "Last run started" stat panel shows how long since
the most recent run and colors it green, yellow, or red based on thresholds. But
there is no way to see historical gaps at a glance or get alerted when a
workflow stops running.

## Approach

Add a state timeline panel to each observed workflow dashboard that highlights
gap periods between runs. Add Grafana-managed alert rules that fire when the gap
exceeds the critical threshold. Restructure the threshold inputs from
color-oriented to semantic.

## Input restructuring

### Current shape

```hcl
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
```

### New shape

```hcl
observe_workflows = {
  "renovate.yml" = {
    title            = "Scheduled maintenance runs for ghalactic/renovate"
    warning_seconds  = 5400
    critical_seconds = 7200
  }
}
```

### Variable definition

```hcl
variable "observe_workflows" {
  description = "Workflows to observe with Grafana dashboards and OTLP logging"
  type = map(object({
    title            = string
    warning_seconds  = number
    critical_seconds = number
  }))
  default = {}
}
```

`warning_seconds` must be less than `critical_seconds`. Terraform validation is
not strictly required since an inverted configuration would produce a
non-harmful but nonsensical dashboard, but it should be documented in the
variable description.

### Color mapping

Colors move from `modules/constants/outputs.tf` into locals in
`modules/repo/observability.tf`:

```hcl
locals {
  threshold_colors = {
    healthy  = "green"
    warning  = "#EAB839"
    critical = "red"
  }
}
```

The `grafana_threshold_colors` output in `modules/constants/outputs.tf` is
removed.

### Threshold step construction

Grafana threshold steps are built from the semantic inputs:

```hcl
locals {
  last_run_started_thresholds = {
    for file, config in var.observe_workflows : file => [
      { value = 0, color = local.threshold_colors.healthy },
      { value = config.warning_seconds, color = local.threshold_colors.warning },
      { value = config.critical_seconds, color = local.threshold_colors.critical },
    ]
  }
}
```

## Grafana folder

A single `grafana_folder` resource named "GitHub Actions" holds both dashboards
and alert rules. The existing `grafana_dashboard.observed_workflow` resources
gain a `folder_uid` pointing to this folder, moving them out of the default
General folder.

## State timeline panel

### Purpose

Show a continuous green/yellow/red bar indicating whether the workflow has run
within the expected intervals over the dashboard time range.

### Queries

Two Loki queries with threshold durations as range parameters:

```logql
# Warning query
count_over_time(
  {service_name="workflow-observability"}
  | event="workflow_run_created"
  | repo="${repo}" | workflow="${workflow}" | trigger="schedule"
  [${warning_seconds}s]
)

# Critical query
count_over_time(
  {service_name="workflow-observability"}
  | event="workflow_run_created"
  | repo="${repo}" | workflow="${workflow}" | trigger="schedule"
  [${critical_seconds}s]
)
```

The threshold durations are injected into the dashboard JSON via Terraform
`templatefile` using placeholder patterns `__WARNING_THRESHOLD_SECONDS__` and
`__CRITICAL_THRESHOLD_SECONDS__`, replaced with `string(config.warning_seconds)`
and `string(config.critical_seconds)` respectively.

### Value mapping

| Warning query | Critical query | State   | Color   |
| ------------- | -------------- | ------- | ------- |
| > 0           | > 0            | Healthy | green   |
| = 0           | > 0            | Delayed | #EAB839 |
| = 0           | = 0            | Missing | red     |

### Layout

- Width: 24 grid columns (full width)
- Height: 4 grid units
- Position: between the existing time series row (y=0, height=8) and the recent
  runs table
- The recent runs table shifts down by 4 units (from y=8 to y=12)

### Templating

The panel definition goes in `grafana/dashboard.json` as a new element
(`panel-5`). Placeholder values `__WARNING_THRESHOLD_SECONDS__` and
`__CRITICAL_THRESHOLD_SECONDS__` in the LogQL `expr` fields are replaced by
Terraform in `observability.tf`.

## Alert rules

### Folder

Alert rules use the same "GitHub Actions" `grafana_folder`.

### Rule group

One `grafana_rule_group` per observed workflow, containing a single alert rule.

### Query

```logql
count_over_time(
  {service_name="workflow-observability"}
  | event="workflow_run_created"
  | repo="${repo}" | workflow="${workflow}" | trigger="schedule"
  [${critical_seconds}s]
)
```

### Condition

Fires when the query returns 0 (no scheduled run within the critical window).

### Timing

- Evaluation interval: 5 minutes
- `for` duration: 0 (the `count_over_time` window provides sufficient buffering)

### Labels

- `repo`: repository name
- `workflow`: workflow display name

### Annotations

- Summary: "No scheduled run of {workflow} in {repo} for over {critical_seconds}
  seconds"

### Contact points

Not configured in Terraform. The user configures notification routing manually
in Grafana Cloud.

## Files changed

| File                            | Change                                                                                                                       |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `modules/repo/variables.tf`     | Replace `last_run_started_thresholds` with `warning_seconds` and `critical_seconds`                                          |
| `modules/repo/observability.tf` | Add threshold color locals, build threshold steps, add folder, alert rule group, update dashboard resource with `folder_uid` |
| `modules/constants/outputs.tf`  | Remove `grafana_threshold_colors` output                                                                                     |
| `grafana/dashboard.json`        | Add panel-5 (state timeline), add layout item, shift panel-4 down                                                            |
| `repos-unique.tf`               | Update `observe_workflows` blocks to new input shape                                                                         |

## Out of scope

- Contact point and notification policy configuration
- Alert silencing or muting rules
- Duration-based thresholds (thresholds on how long each run takes)
- Multi-workflow aggregate health views
