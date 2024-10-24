# FRONT END APP DEPLOYEMENT
resource "kubernetes_deployment" "ltc_frontend"{
  depends_on = [ kubernetes.kubernetes_deployment.ltc_API ]
  metadata {
    name = "frontend"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }

      spec {
        container{
          image = "hilderoc/ltcfront:latest"
          name = "ltcfrontend"
          port{
            container_port = 3000
          }

          env{
            name = "REACT_APP_API_URL"
            value = "http://${kubernetes_service.ltc_API_external.status.0.load_balancer.0.ingress[0].ip}:8000"
          }
        }

      }
    }
  }
}

resource "kubernetes_service" "ltc_frontend" {
  metadata {
    name = "frontend"
  }

  spec {
    selector = {
      app = "frontend"
    }

    port {
      port = 3000
      target_port = 3000
    }

    type = "LoadBalancer"
  }

}