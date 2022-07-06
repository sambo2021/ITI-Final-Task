resource "kubernetes_secret" "dockerhub" {
  metadata {
    name = "dockercreds"
    namespace = "tools"
  }
    type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
          # "${var.registry_server}" = {
          # "username" = var.registry_username
          # "password" = var.registry_password
          # "email"    = var.registry_email
          # "auth"     = base64encode("${var.registry_username}:${var.registry_password}")
          "nexus-repo-svc1.tools.svc.cluster.local:8082" = {
          "username" = "admin"
          "password" = "admin"
          # "auth"     = base64encode("admin:admin")
          
        }
      }
    })
  }
}

resource "kubernetes_secret" "nexushub" {
  metadata {
    name = "nexuscreds"
    namespace = "dev"
  }
 data = {
    "username" = "admin"
    "password" = "admin"

  }
}
