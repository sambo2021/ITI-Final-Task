provider "kubernetes" {
    host = "https://34.211.82.4:49154"
    # client_certificate =     "~/root/.minikube/profiles/minikube/client.crt"
    # client_key =             "~/root/.minikube/profiles/minikube/client.key"
    # cluster_ca_certificate = "~/root/.minikube/ca.crt"
    client_certificate =     file("./client.crt")
    client_key =             file("./client.key")
    cluster_ca_certificate = file("./ca.crt")
  
}

# resource "kubernetes_namespace" "jenkins_namespace" {
#   count = var.create_namespace ? 1 : 0
#   metadata {
#     annotations = {
#       name = "jenkins"
#     }

#     labels = {
#       managedby = "terraform"
#     }

#     name = var.namespace
#   }
# }

# resource "kubernetes_persistent_volume_claim" "claim" {
#   metadata {
#     name      = "${var.name}-claim"
#     namespace = var.namespace
#     labels = {
#       managedby = "terraform"
#     }
#   }
#   spec {
#     access_modes = [var.accessmode]
#     resources {
#       requests = {
#         storage = var.request_storage
#       }
#     }
#     storage_class_name = var.storageclass
#   }
#   depends_on = [
#     kubernetes_namespace.jenkins_namespace
#   ]
# }

# resource "kubernetes_deployment" "jenkins" {
#   depends_on = [
#     kubernetes_namespace.jenkins_namespace
#   ]

#   metadata {
#     name = "${var.name}-deployment"
#     labels = {
#       managedby = "terraform"
#     }
#     namespace = var.namespace
#   }

#   spec {
#     replicas = var.replicas

#     selector {
#       match_labels = {
#         app = var.name
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = var.name
#         }
#       }

#       spec {
#         container {
#           image = var.jenkins_image
#           name  = var.name
#           port {
#             container_port = "8080"
#           }
#           volume_mount {
#             name       = "${var.name}-persistent-storage"
#             mount_path = "/var/jenkins_home"
#           }
#           #   TODO: liveness probe
#         }
#         security_context {
#           fs_group = "1000"
#         }
#         volume {
#           name = "${var.name}-persistent-storage"
#           persistent_volume_claim {
#             claim_name = "${var.name}-claim"
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "jenkins-service" {
#   depends_on = [
#     kubernetes_deployment.jenkins,
#     kubernetes_namespace.jenkins_namespace
#   ]
#   metadata {
#     name      = var.name
#     namespace = var.namespace
#     labels = {
#       managedby = "terraform"
#       service   = var.name
#     }
#   }
#   spec {
#     selector = {
#       app = var.name
#     }
#     port {
#       port        = 8080
#       target_port = 80
#       name = "http"
#     }

#     port {
#       port = 50000
#       name = "tunnel"
#     }

#     type = var.service_type
#   }
# }

# resource "kubernetes_ingress" "jenkins-ingress" {
#   metadata {
#     name = "${var.name}-ingress"
#     namespace = var.namespace
#     annotations = {
#       "kubernetes.io/ingress.class" = "nginx"
#     }
#   }
#   spec {
#     rule {
#       http {
#         path {
#           path = "/*"
#           backend {
#             service_name = kubernetes_service.jenkins-service.metadata.0.name
#             service_port = 80
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service_account" "thia" {
#   metadata {
#     name      = "${var.name}-admin"
#     namespace = var.namespace
#   }
# }

# resource "kubernetes_cluster_role_binding" "this" {
#   metadata {
#     name = "${var.name}-rbac"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "cluster-admin"
#   }
#   subject {
#     kind      = "ServiceAccount"
#     name      = "${var.name}-admin"
#     namespace = var.namespace
#   }
# }







































































# locals {
#  wordpress_labels = {
#    App = "wordpress"
#    Tier = "frontend"
#  }
#  mysql_labels = {
#    App = "wordpress"
#    Tier = "mysql"
#  }
# }
# resource "kubernetes_secret" "mysql-pass" {
#  metadata {
#    name = "mysql-pass"
#  }
#  data = {
#    password = "root"
#  }
# }
# resource "kubernetes_deployment" "wordpress" {
#  metadata {
#    name = "wordpress"
#    labels = local.wordpress_labels
#  }
#  spec {
#    replicas = 1
#    selector {
#      match_labels = local.wordpress_labels
#    }
#    template {
#      metadata {
#        labels = local.wordpress_labels
#      }
#      spec {
#        container {
#          image = "wordpress:4.8-apache"
#          name  = "wordpress"
#          port {
#            container_port = 80
#          }
#          env {
#            name = "WORDPRESS_DB_HOST"
#            value = "mysql-service"
#          }
#          env {
#            name = "WORDPRESS_DB_PASSWORD"
#            value_from {
#              secret_key_ref {
#                name = "mysql-pass"
#                key = "password"
#              }
#            }
#          }
#        }
#      }
#    }
#  }
# }
# resource "kubernetes_service" "wordpress-service" {
#  metadata {
#    name = "wordpress-service"
#  }
#  spec {
#    selector = local.wordpress_labels
#    port {
#      port        = 80
#      target_port = 80
#      node_port = 32000
#    }
#    type = "NodePort"
#  }
# }

# resource "kubernetes_deployment" "mysql" {
#  metadata {
#    name = "mysql"
#    labels = local.mysql_labels
#  }
#  spec {
#    replicas = 1
#    selector {
#      match_labels = local.mysql_labels
#    }
#    template {
#      metadata {
#        labels = local.mysql_labels
#      }
#      spec {
#        container {
#          image = "mysql:5.6"
#          name  = "mysql"
#          port {
#            container_port = 3306
#          }
#          env {
#            name = "MYSQL_ROOT_PASSWORD"
#            value_from {
#              secret_key_ref {
#                name = "mysql-pass"
#                key = "password"
#              }
#            }
#          }
#        }
#      }
#    }
#  }
# }

# resource "kubernetes_service" "mysql-service" {
#  metadata {
#    name = "mysql-service"
#  }
#  spec {
#    selector = local.mysql_labels
#    port {
#      port        = 3306
#      target_port = 3306
#    }
#    type = "NodePort"
#  }
# }