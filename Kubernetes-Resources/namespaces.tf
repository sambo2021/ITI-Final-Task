resource "kubernetes_namespace" "dev-ns" {
  metadata {
    name = "dev"
  }
}
resource "kubernetes_namespace" "tools-ns" {
 metadata {
   name = "tools"
 } 
}