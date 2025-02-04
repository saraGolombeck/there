resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = "kube-system"  # Specify the desired namespace
  repository = "https://kubernetes.github.io/ingress-nginx"  # Helm repo URL for NGINX Ingress Controller
  chart      = "ingress-nginx"
  version    = "4.0.18"  # Specify a version (you can check for the latest one)

  # Set additional values or overrides as needed
  values = [
    <<-EOF
    controller:
      replicaCount: 2
      service:
        externalTrafficPolicy: Local
    EOF
  ]
}