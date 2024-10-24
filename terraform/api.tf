# COSMOS DB CRENDENTIALS 
resource "kubernetes_secret" "cosmosdb_crendentials" {
  metadata {
    name = "cosmosdb-credentials"
  }

  data = {
    COSMOSDB_KEY = var.cosmosdb_key
    COSMODBDB_ENDPOINT = var.cosmosdb_endpoint
  }
}



# API DEPLOYEMENT
resource "kubernetes_deployment" "ltc_API"{
  metadata {
    name = "web-server"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "ltcapi"
      }
    }

    template {
      metadata {
        labels = {
          app = "ltcapi"
        }
      }

      spec {
        container {
          image = "hilderoc/ltcapi:latest"
          name = "ltcapi"
          port {
            container_port = 8000
          }


          env {
            name = "CosmosDBKey"
            value_from {
              secret_key_ref {
                key = "COSMOSDB_KEY"
                name = kubernetes_secret.cosmosdb_crendentials.metadata[0].name
              }
            }
          }

          env {
            name = "CosmosDBEndpoint"
            value_from {
              secret_key_ref {
                key = "COSMODBDB_ENDPOINT"
                name = kubernetes_secret.cosmosdb_crendentials.metadata[0].name
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ltc_API_external" {
  metadata {
    name = "api_external"  
  }

  spec {
    selector = {
      app = "ltcapi"
    }

    port {
      port = 8000
      target_port = 8000
    }

    type = "LoadBalancer"
  }

}

resource "kubernetes_service" "ltc_API_internal" {
  metadata {
    name = "api" # This name is used for internal DNS resolution, used in frontend tf !
  }

  spec {
    selector = {
      app = "ltcapi"
    }

    port {
      port = 8000
      target_port = 8000
    }

    type = "ClusterIP"
  }

}