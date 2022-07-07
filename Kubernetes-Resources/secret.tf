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

   depends_on = [
    kubernetes_namespace.tools-ns
  ]
}






resource "kubernetes_secret" "nexushub" {
  metadata {
    name = "nexuscreds"
    namespace = "dev"
  }
    type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
       
          "10.106.2.226:8082" = {
          "username" = "admin"
          "password" = "admin"
      
          
        }
      }
    })
  }

   depends_on = [
    kubernetes_namespace.dev-ns
  ]
}



