resource "openstack_networking_floatingip_v2" "vpn_gateway_floating_ip" {
  pool = "Ext-Net"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "openstack_compute_keypair_v2" "ssh_keypair" {
  name       = "ssh_key_${replace(var.instance_hostname, ".", "_")}"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_ssh_key" {
  filename        = "./ssh_key_${replace(var.instance_hostname, ".", "_")}"
  content         = tls_private_key.ssh_key.private_key_pem
  file_permission = "0600"
}


resource "openstack_compute_instance_v2" "vpn_server_instance" {
  name        = "VPN-server"
  provider    = openstack.ovh
  image_name  = "Ubuntu 22.04"
  flavor_name = var.instance_flavour
  key_pair    = openstack_compute_keypair_v2.ssh_keypair.name

  network {
    uuid = openstack_networking_network_v2.private_network.id
  }

  security_groups = [openstack_networking_secgroup_v2.vpn_server_sg.name]

  user_data = file("${path.module}/user_data.sh")
}

resource "openstack_compute_floatingip_associate_v2" "vpn_floating_ip_association" {
  floating_ip = openstack_networking_floatingip_v2.vpn_gateway_floating_ip.address
  instance_id = openstack_compute_instance_v2.vpn_server_instance.id
}

output "vpn_server_public_ip" {
  value = openstack_networking_floatingip_v2.vpn_gateway_floating_ip.address
}

resource "null_resource" "add_key_to_user" {
  depends_on = [
    openstack_compute_instance_v2.vpn_server_instance,
    openstack_compute_floatingip_associate_v2.vpn_floating_ip_association
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ssh_key.private_key_pem
    host        = openstack_networking_floatingip_v2.vpn_gateway_floating_ip.address
    port        = 22
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${tls_private_key.ssh_key.public_key_openssh}' > ~/public_key.pem",
    ]
  }
}

resource "null_resource" "fetch_client_config" {
  depends_on = [
    openstack_compute_instance_v2.vpn_server_instance,
    openstack_compute_floatingip_associate_v2.vpn_floating_ip_association
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${local_file.private_ssh_key.filename}")
      host        = openstack_networking_floatingip_v2.vpn_gateway_floating_ip.address
    }

    inline = [
      "while [ ! -f /etc/openvpn/client.ovpn ]; do echo 'Waiting for client.ovpn to be created...'; sleep 5; done"
    ]
  }

  provisioner "local-exec" {
    command = <<EOT
      ssh-add ${local_file.private_ssh_key.filename}
      scp -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ${local_file.private_ssh_key.filename} ubuntu@${openstack_networking_floatingip_v2.vpn_gateway_floating_ip.address}:/etc/openvpn/client.ovpn ./
      sed -i "s/SERVER_PUBLIC_IP/${openstack_networking_floatingip_v2.vpn_gateway_floating_ip.address}/g" ./client.ovpn
    EOT
  }
}


# sudo cat /var/lib/jenkins/secrets/initialAdminPassword