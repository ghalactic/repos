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
