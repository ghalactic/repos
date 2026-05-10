terraform {
  required_version = ">= 1.14.9"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 4.0"
    }
  }
}
