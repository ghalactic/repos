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

variable "ci_workflows" {
  description = "The GitHub Actions CI workflows to use"
  type        = list(string)
  default     = []
}

variable "has_publish_release_workflow" {
  description = "Whether to add a basic GitHub Actions release publishing workflow"
  type        = bool
  default     = true
}

variable "renovate_post_upgrade_command" {
  description = "The Renovate post-upgrade command to use"
  type        = string
  default     = null
}

variable "dependabot_ecosystems" {
  description = "The Dependabot ecosystems to use"
  type        = list(string)
  default     = []
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

variable "has_release_discussions" {
  description = "Whether the repository has release discussions"
  type        = bool
  default     = false
}

variable "release_make_target" {
  description = "The make target to run before publishing releases"
  type        = string
  default     = null
}

variable "release_action_version" {
  description = "The release action version to use when publishing releases"
  type        = string
  default     = null
}
