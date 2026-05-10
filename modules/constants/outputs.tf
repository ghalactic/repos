output "committer" {
  description = "The committer details to use when committing files to GitHub"
  value = {
    name  = "ghalactic-repo-manager[bot]"
    email = "127176271+ghalactic-repo-manager[bot]@users.noreply.github.com"
  }
}

output "license" {
  description = "The repository license"
  value       = file("LICENSE")
}

output "org" {
  description = "The GitHub organization"
  value       = "ghalactic"
}

output "org_name" {
  description = "The GitHub organization's display name"
  value       = "Ghalactic"
}

locals {
  issue_label_color_renovate          = "0366d6"
  issue_label_color_renovate_safe     = "168700"
  issue_label_color_renovate_unsafe   = "d93f0b"
  issue_label_color_renovate_security = "d73a4a"
}

output "issue_labels" {
  description = "The issue labels to use"
  value = {
    blocked = {
      name        = "blocked"
      description = "Can't be worked on until something else is done"
      color       = "d876e3"
    }

    renovate = {
      name        = "renovate"
      description = "Pull requests created by Renovate"
      color       = local.issue_label_color_renovate
    }

    docker = {
      name        = "docker"
      description = "Pull requests that update Docker dependencies"
      color       = local.issue_label_color_renovate
    }

    github-actions = {
      name        = "github-actions"
      description = "Pull requests that update GitHub Actions dependencies"
      color       = local.issue_label_color_renovate
    }

    gomod = {
      name        = "gomod"
      description = "Pull requests that update gomod dependencies"
      color       = local.issue_label_color_renovate
    }

    gradle = {
      name        = "gradle"
      description = "Pull requests that update Gradle dependencies"
      color       = local.issue_label_color_renovate
    }

    helm = {
      name        = "helm"
      description = "Pull requests that update Helm dependencies"
      color       = local.issue_label_color_renovate
    }

    npm = {
      name        = "npm"
      description = "Pull requests that update NPM dependencies"
      color       = local.issue_label_color_renovate
    }

    nuget = {
      name        = "nuget"
      description = "Pull requests that update NuGet dependencies"
      color       = local.issue_label_color_renovate
    }

    swift = {
      name        = "swift"
      description = "Pull requests that update Swift dependencies"
      color       = local.issue_label_color_renovate
    }

    terraform = {
      name        = "terraform"
      description = "Pull requests that update Terraform dependencies"
      color       = local.issue_label_color_renovate
    }

    major = {
      name        = "major"
      description = "Pull requests that update major dependency versions"
      color       = local.issue_label_color_renovate_unsafe
    }

    non-major = {
      name        = "non-major"
      description = "Pull requests that update non-major dependency versions"
      color       = local.issue_label_color_renovate_safe
    }

    non-dev = {
      name        = "non-dev"
      description = "Pull requests that update non-dev dependencies"
      color       = local.issue_label_color_renovate_unsafe
    }

    dev = {
      name        = "dev"
      description = "Pull requests that update dev dependencies"
      color       = local.issue_label_color_renovate_safe
    }

    trusted = {
      name        = "trusted"
      description = "Pull requests that update trusted dependencies"
      color       = local.issue_label_color_renovate_safe
    }

    security = {
      name        = "security"
      description = "Pull requests that address security vulnerabilities"
      color       = local.issue_label_color_renovate_security
    }
  }
}
