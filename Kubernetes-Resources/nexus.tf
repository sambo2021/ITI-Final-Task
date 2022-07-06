resource "kubernetes_persistent_volume_claim" "nexus-pvc" {
    metadata {
      name = "nexus-pv-claim"
      namespace = "tools"
    }
    spec {
      access_modes = [ "ReadWriteOnce" ]
      resources {
        requests = {
          "storage" = "5Gi"
        }
      }
    }

 depends_on = [
    kubernetes_namespace.tools-ns
  ]
}

resource "kubernetes_service" "nexus-svc" {
    metadata {
      name = "nexus-svc"
      namespace = "tools"
    }

    spec {
      port {
        port = 8081
        protocol = "TCP"
        target_port = 8081
        node_port = 32001
      }
      selector = {
        "app" = "nexus"
      }
      type = "NodePort" 
    }
 depends_on = [
    kubernetes_namespace.tools-ns
  ]
}









resource "kubernetes_service" "nexus-repo-svc" {
    metadata {
      name = "nexus-repo-svc1"
      namespace = "tools"
    }

    spec {
      port {
        port = 8082
        protocol = "TCP"
        target_port = 8082
      }
      selector = {
        "app" = "nexus"
      }
      type = "ClusterIP" 
    }

}













resource "kubernetes_deployment" "nexus" {
  metadata {
    name = "nexus-deployment"
    namespace = "tools"
    labels = {
        app = "nexus"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app" = "nexus"
      }
    }
    template {
      metadata {
        labels = {
            app = "nexus"
        }
      }
      spec {
        container {
          name = "nexus"
          image = "sonatype/nexus3:3.39.0"
          resources {
            limits = {
              cpu    = "1000m"
              memory = "4Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "2Gi"
            }
          }
          port {
            container_port = 8081
          }
         volume_mount {
           name = "nexus-data"
           mount_path = "/nexus-data"
         }
        }
        volume {
          name = "nexus-data"
          persistent_volume_claim {
            claim_name = "nexus-pv-claim"
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.tools-ns
  ]
}