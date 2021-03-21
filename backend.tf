terraform {
  backend "remote" {
    organization = "sikademo"
    workspaces {
      name = "gitlab"
    }
  }
}
