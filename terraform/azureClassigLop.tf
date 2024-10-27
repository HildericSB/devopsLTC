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
