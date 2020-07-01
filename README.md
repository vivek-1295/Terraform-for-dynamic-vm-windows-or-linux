# Terraform for Dynamic Azure VM
### Dynamic VM creation for Windows or Linux's

This Terraform code will create VM for windows or for linux's with its necessary resource

  - Virtual Network
  - Public IP
  - Network Interface - NIC
  - Subnet - Inside Virtual Network

# Terraform Azurerm
  - Provider version is 2.16
  - This terraform code is capable for azurerm provider version 2.0.0+

```sh
 provider "azurerm" {
  version = "=2.16"
  features {}
 }
```
> Set `version` as per requirement.  

# How to create Windows VM or Linux's VM
#### For Windows:
**Windows** Virtual Machine (VM) creation is very simple and easy

- required to set one variable __`os_type`__ in `terraform.tfvars`
```sh
    os_type = "Windows"
```
> This will ensure it will create only **Windows Virtual Machine**

#### For Linux's:
**Linux's** Virtual Machine (VM) creation is very simple and easy

- required to set one variable __`os_type`__ in terraform.tfvars
```sh
    os_type = "Linux"
```
> This will ensure it will create only **Linux's Virtual Machine**

### More Suitable Configuration for Windows or Linuxs image 

List of image obtain by running azure-cli command given in following link
[click here for more information](https://docs.microsoft.com/en-us/cli/azure/vm/image?view=azure-cli-latest#az-vm-image-list)

Example: To obtain list of **`Windows image`** available in **`West Europe`**
```sh
az vm image list -p MicrosoftWindowsServer -l 'West Europe' --all
```
In Terraform code `main.tf` provide input values for following block of code to the respective variables

**`For Windows Image:`**
only when `os_type = "Windows"`
```sh
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
```
**`For Linux's Image:`**
only when `os_type = "Linux"`
```sh
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
```

## To Run Terraform
### Terraform Init & Plan
Initialize Terraform
```bash
terraform init
```
Review Terraform execution plan
```bash
terraform plan
```

### Terraform Apply
Execute previous generated execution plan
```bash
terraform apply
```

### Terraform clean-up
Destroy resources created by Terraform
```bash
terraform destroy
```

##### To see more upcoming `Terraform code`

[**click on this link**](https://github.com/vivek-1295)

