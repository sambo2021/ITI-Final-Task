resource "kubernetes_service_account" "jenkins-sa" {
  metadata {
    name = "jenkins-admin"
    namespace = "tools"
  }
}
resource "kubernetes_cluster_role" "jenkins-role" {
  metadata {
    name = "jenkins-role"
    labels = {
      "app.kubernetes.io/name" = "jenkins"
    }
  }
  rule {
    api_groups = [ "" ]
    resources = [ "pods" , "services", "secrets", "configmaps"]
    verbs = ["create","delete","get","list","patch","update","watch"]
  }
  rule {
    api_groups = [ "apps" ]
    resources = [ "deployments" ]
    verbs = ["create","delete","get","list","patch","update","watch"]
  }
}
resource "kubernetes_cluster_role_binding" "jenkins-role-binding" {
    metadata {
      name = "jenkins-role-binding"
    }
    role_ref {
      api_group = "rbac.authorization.k8s.io"
      kind = "ClusterRole"
      name = "jenkins-role"
    }
    subject {
      kind = "ServiceAccount"
      name = "jenkins-admin"
      namespace = "tools"
    }
  
}
resource "kubernetes_persistent_volume_claim" "jenkins-pvc" {
    metadata {
      name = "jenkins-pv-claim"
      namespace = "tools"
    }
    spec {
      access_modes = [ "ReadWriteOnce" ]
      resources {
        requests = {
          "storage" = "10Gi"
        }
      }
    }
}

resource "kubernetes_service" "jenkins-svc" {
    metadata {
      name = "jenkins-svc"
      namespace = "tools"
    }

    spec {
      port {
        name = "httpport"
        port = 8080
        protocol = "TCP"
        target_port = 8080
        node_port = 32000
      }
      port {
        name = "jnlpport"
        port = 50000
        target_port = 50000
      }
      selector = {
        "app" = "jenkins"
      }
      type = "NodePort" 
    }

}
resource "kubernetes_deployment" "jenkins" {
  metadata {
    name = "jenkins-deployment"
    namespace = "tools"
    labels = {
        app = "jenkins"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app" = "jenkins"
      }
    }
    template {
      metadata {
        labels = {
            app = "jenkins"
        }
      }
      spec {
        service_account_name = "jenkins-admin"
        security_context {
          fs_group = 1000
          run_as_user = 1000
        }
        container {
          name = "jenkins"
          image = "jenkins/jenkins:lts"
          resources {
            limits = {
              cpu    = "1000m"
              memory = "4Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "500Mi"
            }
          }
          port {
            name = "httpport"
            container_port = 8080
          }
          port {
            name = "jnlpport"
            container_port =  50000
          }
          liveness_probe {
            http_get {
              path = "/login"
              port = 8080
            }
            initial_delay_seconds = 90
            period_seconds = 10
            timeout_seconds = 5
            failure_threshold = 5
          }
          readiness_probe {
            http_get {
              path = "/login"
              port = 8080
            }
            initial_delay_seconds = 60
            period_seconds = 10
            timeout_seconds = 5
            failure_threshold = 3
          }
         volume_mount {
           name = "jenkins-data"
           mount_path = "/var/jenkins_home"
         }
        }
        volume {
          name = "jenkins-data"
          persistent_volume_claim {
            claim_name = "jenkins-pv-claim"
          }
        }
      }
    }
  }
}