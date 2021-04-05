variable "prefix" {
  description = "The prefix that will be used for all resoruces."
}
variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "West US 2"
}
variable "vm-count" {
  description = "The amount of VMs that will be created."
}
variable "vm-update-count" {
  description = "The amount of VMs that will be created when a specific one is updating the OS system."
  default     = 5
}
variable "vm-fault-count" {
  description = "The amount of VMs that will be created when a specific one is failing or having any kind of issues."
  default     = 3
}
