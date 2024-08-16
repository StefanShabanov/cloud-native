# Security group for the VPN server
resource "openstack_networking_secgroup_v2" "vpn_server_sg" {
  name = "vpn-server-sg"
}

#rule for OpenVPN traffic
resource "openstack_networking_secgroup_rule_v2" "openvpn_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1194
  port_range_max    = 1194
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.vpn_server_sg.id
}

#rule to allow outbound traffic to the private subnet
resource "openstack_networking_secgroup_rule_v2" "vpn_to_private_rule" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = var.private_subnet
  security_group_id = openstack_networking_secgroup_v2.vpn_server_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "vpn_to_private_rule_udp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = var.private_subnet
  security_group_id = openstack_networking_secgroup_v2.vpn_server_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "vpn_to_private_rule_icmp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = var.private_subnet
  security_group_id = openstack_networking_secgroup_v2.vpn_server_sg.id
}

#rule to allow ICMP traffic from the VPN subnet to the VPN server
resource "openstack_networking_secgroup_rule_v2" "vpn_ingress_icmp_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = var.vpn_subnet
  security_group_id = openstack_networking_secgroup_v2.vpn_server_sg.id
}

#rule to allow all TCP traffic from the VPN subnet to the VPN server
resource "openstack_networking_secgroup_rule_v2" "vpn_ingress_all_tcp_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = var.vpn_subnet
  security_group_id = openstack_networking_secgroup_v2.vpn_server_sg.id
}

#rule to allow all UDP traffic from the VPN subnet to the VPN server
resource "openstack_networking_secgroup_rule_v2" "vpn_ingress_all_udp_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = var.vpn_subnet
  security_group_id = openstack_networking_secgroup_v2.vpn_server_sg.id
}

#rule for SSH access from anywhere (for testing)
resource "openstack_networking_secgroup_rule_v2" "ssh_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.ssh_port
  port_range_max    = var.ssh_port
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.vpn_server_sg.id
}


########### WWW ingress/egress

resource "openstack_networking_secgroup_rule_v2" "vpn_ingress_web_subnet" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "10.0.4.0/24"
  security_group_id = openstack_networking_secgroup_v2.vpn_server_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "vpn_egress_web_subnet" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "10.0.4.0/24"
  security_group_id = openstack_networking_secgroup_v2.vpn_server_sg.id
}