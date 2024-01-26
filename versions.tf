terraform {
  cloud {
    organization = "fiap-lanches-organization"

    workspaces {
      name = "fiap-lanches-workspace"
    }
  }
}
