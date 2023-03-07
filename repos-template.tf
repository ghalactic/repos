module "repo_docker_node_action_template" {
  source      = "./modules/repo"
  name        = "docker-node-action-template"
  description = "A template repo for Docker + Node.js GitHub Actions"

  ci_workflows = ["node"]

  is_template = true
}
