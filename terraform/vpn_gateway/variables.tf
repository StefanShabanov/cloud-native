variable "instance_flavour" {
  description = "Instance flavour"
  default     = "d2-2"
}

variable "instance_hostname" {
  description = "Instance hostname"
  default     = "VPN-Server"
}

variable "private_subnet" {
  description = "IP range of the private subnet"
  default     = "10.1.0.0/24"
}

variable "vpn_subnet" {
  description = "IP range of the VPN subnet"
  default     = "10.8.0.0/24"
}

variable "ssh_port" {
  description = "Port number for SSH access"
  default     = 22
}

variable "a_instance_hostname" {
  description = "Instance hostname"
  default     = "VPN-Server"
}

variable "b_instance_flavour" {
  description = "Enter the desired instance flavour:"
  default     = "d2-2"
}

variable "app_key" {
  description = "OpenStack API app key"
  sensitive   = true
}
variable "app_secret" {
  description = "OpenStack API app secret key"
  sensitive   = true
}
variable "cons_key" {
  description = "OpenStack API app consumer key"
  sensitive   = true
}