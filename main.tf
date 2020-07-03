#Azure Provider 2.16
provider "azurerm" {
  version = "=2.16"
  features {}
}

#local for dynamic use to config windows or linux properties
locals {
  linux   = var.os_type == "Linux" ? { dummy_create = true } : {}
  windows = var.os_type == "Windows" ? { dummy_create = true } : {}
}

#Resource
resource "azurerm_resource_group" "main" {
  name     = "example"
  location = "West Europe"
}

#Vnet
resource "azurerm_virtual_network" "main" {
  name                = "vnet-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

#Subnet
resource "azurerm_subnet" "Subnetinternal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

#NIC
resource "azurerm_network_interface" "main" {
  name                = "nic-network"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnetinternal.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address            = "10.0.2.5"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

#VM
resource "azurerm_virtual_machine" "main" {
  name                  = "AutoOS-VM"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  #Windows image
  dynamic "storage_image_reference" {
    for_each = local.windows
    content {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2016-Datacenter"
      version   = "latest"
    }
  }

  #linux image
  dynamic "storage_image_reference" {
    for_each = local.linux
    content {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "16.04-LTS"
      version   = "latest"
    }
  }

  #OS Disk
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    os_type           = var.os_type
  }
  #OS Profile
  os_profile {
    computer_name  = "vmlinux"
    admin_username = "AdminUser"
    admin_password = "Password@123456"
  }

  #linux [Note: Setting disable_password_authentication to false, because don't want to use SSH Authentication]
  dynamic "os_profile_linux_config" {
    for_each = local.linux
    content {
      disable_password_authentication = false
      ssh_keys {
        path     = "/home/AdminUser/.ssh/authorized_keys"
        key_data = ""
      }
    }
  }

  #Windows
  dynamic "os_profile_windows_config" {
    for_each = local.windows
    content {
      enable_automatic_upgrades = true
      provision_vm_agent        = true
    }
  }

  tags = {
    Vivek = "Auto vm os"
  }
}

//Public Ip
resource "azurerm_public_ip" "main" {
  name                = "PublicIp-netwowk"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"

  tags = {
    Vivek = "public_ip"
  }
}