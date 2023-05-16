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

variable "default_branch" {
  description = "The default branch name"
  type        = string
  default     = "main"
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

variable "publish_release_workflow" {
  description = "Whether to add a basic GitHub Actions release publishing workflow"
  type        = bool
  default     = true
}

variable "dependabot_ecosystems" {
  description = "The Dependabot ecosystems to use"
  type        = list(string)
  default     = []
}
