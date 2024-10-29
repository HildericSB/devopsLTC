
# AZURE CLASSIC CONTAINER INSIGHTS SOLUTION
# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "LtcAnalyticWorkspace" {
  name                = "LtcAnalyticWorkspace"
  location            = azurerm_resource_group.ltcDevOps.location
  resource_group_name = azurerm_resource_group.ltcDevOps.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


# Enable Container Insights solution
resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "ContainerInsights"
  location             = azurerm_resource_group.ltcDevOps.location
  resource_group_name  = azurerm_resource_group.ltcDevOps.name
  workspace_resource_id = azurerm_log_analytics_workspace.LtcAnalyticWorkspace.id
  workspace_name       = azurerm_log_analytics_workspace.LtcAnalyticWorkspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}


# PROMETHEUS SOLUTIONS
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus"{
    name = "prometheus"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "kube-prometheus-stack"
    namespace = kubernetes_namespace.monitoring.metadata.0.name
    version = "65.5.0"

  values = [
    file("${path.module}/prometheus-values.yaml")
  ]

}

