

resource "azurerm_kubernetes_cluster" "k8s" {
    location = azurerm_resource_group.ltcDevOps.location
    name = "K8S_cluster_ltc"
    resource_group_name = azurerm_resource_group.ltcDevOps.name
    dns_prefix          = "ltcCluster"

    default_node_pool {
        name = "agentpool"
        node_count = 2
        vm_size    = "Standard_B2s"
    }

  identity {
    type = "SystemAssigned"
  }
  
}


variable "cosmosdb_key" {
  description = "CosmosDB key"
  type        = string
}

variable "cosmosdb_endpoint" {
  description = "cosmosdb_endpoint"
  type        = string
}

resource "kubernetes_secret" "cosmosdb_crendentials" {
  metadata {
    name = "cosmosdb-credentials"
  }

  data = {
    COSMOSDB_KEY = var.cosmosdb_key
    COSMODBDB_ENDPOINT = var.cosmosdb_endpoint
  }
}

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

resource "kubernetes_service" "ltc_API" {
  metadata {
    name = "api"
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