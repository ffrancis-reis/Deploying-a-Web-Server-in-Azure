provider "azurerm" {
  features {}
  # subscription_id = "00000000-0000-0000-0000-000000000000"
  # client_id       = "00000000-0000-0000-0000-000000000000"
  # client_secret   = var.client_secret

}

data "azurerm_image" "main" {
  name                = "ubuntuImage"
  resource_group_name = "web-service-image-rg"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = {
    "environment" : "Development"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vn"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/22"]

  tags = {
    "environment" : "Development"
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  security_rule {
    name                       = "allow-vms-access"
    protocol                   = "*"
    access                     = "Allow"
    priority                   = 100
    direction                  = "Inbound"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    "environment" : "Development"
  }
}

resource "azurerm_network_security_rule" "deny-internet" {
  name                        = "deny-internet-access"
  protocol                    = "*"
  access                      = "Deny"
  priority                    = 4096
  direction                   = "Outbound"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_interface" "main" {
  count               = var.vm-count > 5 ? 5 : var.vm-count
  name                = "${var.prefix}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    "environment" : "Development"
  }
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = {
    environment = "Development"
  }
}

resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  frontend_ip_configuration {
    name = "PublicIPAddress"
    # subnet_id            = azurerm_subnet.internal.id
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = {
    "environment" : "Development"
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  name            = "${var.prefix}-lb-pool"
  loadbalancer_id = azurerm_lb.main.id
}

resource "azurerm_availability_set" "main" {
  name                         = "${var.prefix}-av-set"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  platform_update_domain_count = var.vm-update-count
  platform_fault_domain_count  = var.vm-fault-count

  tags = {
    "environment" : "Development"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.vm-count > 5 ? 5 : var.vm-count
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  network_interface_ids           = [azurerm_network_interface.main[count.index].id]
  size                            = "Standard_B1ls"
  admin_username                  = "alphaadmin"
  admin_password                  = "alphaP@ss"
  disable_password_authentication = false
  source_image_id                 = data.azurerm_image.main.id

  # admin_ssh_key {
  #   public_key = file("~/.ssh/id_rsa.pub")
  # }

  os_disk {
    name                 = "${var.prefix}-vm-${count.index}-mdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    # disk_size_gb         = "5"
  }

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  tags = {
    "environment" : "Development"
  }
}

resource "azurerm_managed_disk" "main" {
  name                 = "${var.prefix}-mdisk"
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  storage_account_type = "Standard_LRS"
  disk_size_gb         = "5"
  create_option        = "Empty"

  tags = {
    "environment" : "Development"
  }
}
