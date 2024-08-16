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

variable "instance_flavour" {
  description = "Hostname for the instance"
  default = "d2-2"
}

variable "instance_hostname" {
  description = "Hostname for Jenkins host"
  default     = "svc01"
}

variable "ssh_port" {
  description = "Change this value if you want SSH default port (22) to be changed to uncommon one"
  default     = 22
}

variable "private_network_id" {}
variable "microservices_workload_sg_id" {}