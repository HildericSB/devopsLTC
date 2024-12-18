


#K8s CLUSTER DEPLOYEMENT
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

  # AKS cluster monitoring addon
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.LtcAnalyticWorkspace.id
  }
  
}

resource "azurerm_resource_group" "ltcDevOps" {
  name     = "ltcDevOpsRG"
  location = "northeurope"
}



