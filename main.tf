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
 # create a virtual network#
resource "azurerm_virtual_network" "vnet" {
  name = "myTFVnet"
  address_space = ["10.0.0.0/16","10.1.0.0/16","10.2.0.0/16"]
  location  = "westus2"
  
  # Terraform versions below 0.12 require interpolation syntax ${...}, from 0.12 and beyond the following exression is used #
  resource_group_name = azurerm_resource_group.rg1.name
  }
 #create a subnet#
resource "azurerm_subnet" "subnet1" {
  name  = "myTFSubnet"
  resource_group_name = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix  = "10.0.1.0/24"
  }

#create a public IP#
resource "azurerm_public_ip" "publicip1" {
  name  = "myTFPublicIP"
  location  = "westus2"
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method = "Static"
  }

#Create Network Security Group and rule#
resource "azurerm_network_security_group" "nsg1" {
  name  = "myTFNSG"
  location  = "westus2"
  resource_group_name = azurerm_resource_group.rg1.name
  
  security_rule {
    name  = "SSH"
    priority  = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tco"
    source_port_range = "*"
    destination_port_range  = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    }
  }

#Create network interface#
resource "azurerm_network_interface" "nic1" {
  name  = "myNIC"
  location  = "westus2"
  resource_group_name = azurerm_resource_group.rg1.name
  network_security_group_id = azurerm_network_security_group.nsg1.id
  
  ip_configuration {
    name  = "myNICConfg"
    subnet_id = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id  = azurerm_public_ip.publicip1.id
  }
}

#creat a linux virtual machine#
resource "azurerm_virtual_machine" "vm1" {
  name  = "myTFVM"
  location  = "westus2"
  resource_group_name = azurerm_resource_group.rg1.name
  network_interfae_ids  = [azurerm_network_interface.nic1.id]
  vm_size = "Standard_DS1_v2"
  
  storage_os_disk {
    name  = "myOsDisk"
    caching  = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Premium_LRS"
    }
  
  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04.0-LTS"
    version = "latest"
    }
  
  os_profile {
    computer_name = "myTFVM"
    admin_username = "plankton"
    admin_password = "Password1234!"
    }
  
  os_profile_linux_config {
    disable_password_authentication = flase
    }
  }
output "ip" {
  value = azurerm_public_ip.publicip1.ip_address
  }










