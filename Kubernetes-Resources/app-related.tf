resource "kubernetes_secret" "dv-secret" {
  metadata {
    name = "db-secret"
    namespace = "dev"
  }
  data = {
    "MYSQL_ROOT_PASSWORD" = "password"
    "MYSQL_DATABASE" = "db"

  }
}
resource "kubernetes_secret" "app-secret" {
  metadata {
    name = "app-secret"
    namespace = "dev"
  }
  data = {
    "HOST" = "db-svc.dev.svc.cluster.local"
    "USERNAME" = "root"
    "PASSWORD" = "password"
    "DATABASE" = "db"
  }
}