output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}
output "host" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.host
  sensitive = true
}

# Output the web server's public IP
output "web_server_ip" {
  value = kubernetes_service.ltc_frontend.status.0.load_balancer.0.ingress.0.ip
}

output "ltc_API_ip" {
  value = kubernetes_service.ltc_API_external.status.0.load_balancer.0.ingress.0.ip
}

/* # OUTPUT PROMETHEUS. !!!! NOT TESTED !!!!
data "kubernetes_service" "prometheus"{
  metadata {
    name = "prometheus-kube-prometheus"
    namespace = kubernetes_namespace.monitoring.metadata.0.name
  }
  depends_on = [ helm_release.prometheus ]
}

data "kubernetes_service" "grafana"{
  metadata {
    name = "prometheus-grafana"
    namespace = kubernetes_namespace.monitoring.metadata.0.name
  }
  depends_on = [ helm_release.prometheus ]
}


output "grafana_ip"{
  value = data.kubernetes_service.grafana.status.0.load_balancer.0.ingress.0.ip
}

output "prometheus"{
  value = data.kubernetes_service.prometheus.status.0.load_balancer.0.ingress.0.ip
} */