#www workload sg
resource "openstack_networking_secgroup_v2" "jenkins_sg" {
  name = "web-workload-sg"
}

#22 ingress
resource "openstack_networking_secgroup_rule_v2" "web_ingress_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.jenkins_sg.id
}

#80 ingress
resource "openstack_networking_secgroup_rule_v2" "web_ingress_http_private_network" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.jenkins_sg.id
}

#443 ingress
resource "openstack_networking_secgroup_rule_v2" "web_ingress_https_private_network" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.jenkins_sg.id
}

#ICMP ingress
resource "openstack_networking_secgroup_rule_v2" "web_ingress_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.jenkins_sg.id
}

#22 egress
resource "openstack_networking_secgroup_rule_v2" "web_egress_ssh" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.jenkins_sg.id
}

#80 egress
resource "openstack_networking_secgroup_rule_v2" "web_egress_http" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.jenkins_sg.id
}

#443 egress
resource "openstack_networking_secgroup_rule_v2" "web_egress_https" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.jenkins_sg.id
}

#ICMP egress
resource "openstack_networking_secgroup_rule_v2" "web_egress_icmp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.jenkins_sg.id
}

# HTTP (port 80) from anywhere
resource "openstack_networking_secgroup_rule_v2" "web_ingress_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.jenkins_sg.id
}

# HTTPS (port 443) from anywhere
resource "openstack_networking_secgroup_rule_v2" "web_ingress_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.jenkins_sg.id
}

# 8080 ingress (Jenkins) from anywhere
resource "openstack_networking_secgroup_rule_v2" "web_ingress_jenkins" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8080
  port_range_max    = 8080
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.jenkins_sg.id
}



output "jenkins_sg" {
  value = openstack_networking_secgroup_v2.jenkins_sg.id
}