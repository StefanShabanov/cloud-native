# Private network
resource "openstack_networking_network_v2" "private_network" {
  name = "private-network"
}

# Private subnet
resource "openstack_networking_subnet_v2" "private_subnet" {
  name       = "private-subnet"
  network_id = openstack_networking_network_v2.private_network.id
  cidr       = "10.0.0.0/16"
  ip_version = 4
  gateway_ip = "10.0.0.1"
}

# Router
resource "openstack_networking_router_v2" "router" {
  name                = "router"
  admin_state_up      = "true"
  external_network_id = var.external_network_id
}

# Private subnet to the router attachment
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.private_subnet.id
}