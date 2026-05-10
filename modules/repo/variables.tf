module "constants" {
  source = "../constants"
}

variable "name" {
  description = "The repository name"
  type        = string
}

variable "description" {
  description = "The repository description"
  type        = string
}

variable "topics" {
  description = "The repository topics"
  type        = list(string)
  default     = []
}

variable "homepage_url" {
  description = "The homepage URL"
  type        = string
  default     = null
}

variable "is_template" {
  description = "Whether the repository is a template"
  type        = bool
  default     = false
}

variable "template" {
  description = "The template repo to use"
  type        = object({ owner = string, repository = string })
  default     = null
}

variable "pages_branch" {
  description = "The pages branch to use"
  type        = string
  default     = null
}

variable "manage_renovate" {
  description = "Whether to manage the Renovate configuration"
  type        = bool
  default     = true
}

variable "renovate_post_upgrade_command" {
  description = "The Renovate post-upgrade command to use"
  type        = string
  default     = null
}

variable "has_actions" {
  description = "Whether the repository has GitHub Actions enabled"
  type        = bool
  default     = true
}

variable "has_discussions" {
  description = "Whether the repository has discussions"
  type        = bool
  default     = false
}

variable "has_projects" {
  description = "Whether the repository has projects"
  type        = bool
  default     = false
}

variable "release_make_target" {
  description = "The make target to run before publishing releases"
  type        = string
  default     = null
}

variable "use_release_action_main" {
  description = "Use the main branch version of the release action when publishing releases"
  type        = bool
  default     = false
}

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

  validation {
    condition     = var.grafana_folder_uid != null || length(var.observe_workflows) == 0
    error_message = "grafana_folder_uid is required when observe_workflows is non-empty."
  }
}

variable "grafana_loki_datasource_uid" {
  description = "The UID of the Grafana Loki datasource for alert rule queries"
  type        = string
  default     = null

  validation {
    condition     = var.grafana_loki_datasource_uid != null || length(var.observe_workflows) == 0
    error_message = "grafana_loki_datasource_uid is required when observe_workflows is non-empty."
  }
}
