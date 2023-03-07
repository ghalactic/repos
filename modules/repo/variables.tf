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

variable "ci_workflows" {
  description = "The GitHub Actions CI workflows to use"
  type        = list(string)
  default     = []
}

variable "dependabot_ecosystems" {
  description = "The Dependabot ecosystems to use"
  type        = list(string)
  default     = []
}
