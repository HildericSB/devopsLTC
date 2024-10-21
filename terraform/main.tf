

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.6.0"
    }
  }

}

provider "azurerm" {
  features {}
}

# Configure the Kubernetes provider
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}

resource "azurerm_resource_group" "ltcDevOps" {
  name     = "ltcDevOpsRG"
  location = "northeurope"
}

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