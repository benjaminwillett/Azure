# Azure provider non-beta versions between 1.32.0 and 1.33.0 using the ~> pessimistic constrain operator #
provider "azurerm" {
  version = "~>1.32.0"
  
# the prefered authentication mechanism for Azure is managed identity #

  use_msi = true
  subscription_id = "<id details>"
  tenant_id = "<tenant details>"
}

# create a new resource group #
resource "azurerm_resource_group" "rg1" {
  name = "myTFResourceGroup"
  location = "westus"
  tags = {
    Environment = "Production"
    Team = "DevOps"
}
}
