# FRONT END APP DEPLOYEMENT
resource "kubernetes_deployment" "ltc_frontend"{
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
            name = "API_URL"
            value = "http://api:8000"
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