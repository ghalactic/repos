output "workflow_dashboard_public_urls" {
  description = "A map of repository names to maps of observed workflow names and their public Grafana dashboard URLs."
  value = {
    (module.repo_renovate.name)       = module.repo_renovate.workflow_dashboard_public_urls
    (module.repo_token_provider.name) = module.repo_token_provider.workflow_dashboard_public_urls
  }
}
