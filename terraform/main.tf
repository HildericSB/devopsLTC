


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

    oms_agent {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.workspaceLTC.id
      msi_auth_for_monitoring_enabled = true
    }
}


resource "azurerm_log_analytics_workspace" "workspaceLTC" {
  name                = "workspaceLTC"
  resource_group_name = azurerm_resource_group.ltcDevOps.name
  location            = azurerm_resource_group.ltcDevOps.location
}

resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                = "MSCI-${azurerm_log_analytics_workspace.workspaceLTC.location}-${azurerm_kubernetes_cluster.k8s.name}"
  resource_group_name = azurerm_resource_group.ltcDevOps.name
  location            = azurerm_log_analytics_workspace.workspaceLTC.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.workspaceLTC.id
      name                  = "ciworkspace"
    }
  }

  data_flow {
    streams      = var.streams
    destinations = ["ciworkspace"]
  }

  data_flow {
    streams      = [ "Microsoft-Syslog"]
    destinations = ["ciworkspace"]
  }

  data_sources {
    syslog{
      streams            = ["Microsoft-Syslog"]
      facility_names      = var.syslog_facilities
      log_levels          = var.syslog_levels
      name               = "sysLogsDataSource"
    }

    extension {
      streams            = var.streams
      extension_name     = "ContainerInsights"
      extension_json     = jsonencode({
        "dataCollectionSettings" : {
            "interval": var.data_collection_interval,
            "namespaceFilteringMode": var.namespace_filtering_mode_for_data_collection,
            "namespaces": var.namespaces_for_data_collection
            "enableContainerLogV2": var.enableContainerLogV2
        }
      })
      name               = "ContainerInsightsExtension"
    }
  }

  description = "DCR for Azure Monitor Container Insights"
}

resource "azurerm_monitor_data_collection_rule_association" "dcra" {
  name                        = "ContainerInsightsExtension"
  target_resource_id          = azurerm_kubernetes_cluster.k8s.id
  data_collection_rule_id     = azurerm_monitor_data_collection_rule.dcr.id
  description                 = "Association of container insights data collection rule. Deleting this association will break the data collection for this AKS Cluster."
}
