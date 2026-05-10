terraform {
  backend "remote" {
    organization = "ghalactic"

    workspaces {
      name = "repos"
    }
  }
}
