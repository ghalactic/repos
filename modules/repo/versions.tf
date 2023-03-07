terraform {
  required_version = ">= 1.0.11"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}
