data "terraform_remote_state" "vpn_private_network" {
  backend = "local"
  config = {
    path = "../vpn_gateway/terraform.tfstate"
  }
}

data "terraform_remote_state" "jenkins_sg" {
  backend = "local"
  config = {
    path = "../vpn_gateway/terraform.tfstate"
  }
}


resource "openstack_networking_floatingip_v2" "microservices_floating_ip" {
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
  filename        = "ssh_key_${replace(var.instance_hostname, ".", "_")}"
  content         = tls_private_key.ssh_key.private_key_pem
  file_permission = "0600"
}

locals {
  base_ip_prefix      = "10.0.2."
  instance_number_str = regex("[0-9]+", var.instance_hostname) #https://developer.hashicorp.com/terraform/language/functions/regex
  instance_number     = tonumber(local.instance_number_str)    #https://developer.hashicorp.com/terraform/language/functions/tonumber
  instance_ip         = "${local.base_ip_prefix}${local.instance_number}"
}

resource "openstack_compute_instance_v2" "jenkins_instance" {
  name        = var.instance_hostname
  provider    = openstack.ovh
  image_name  = "Ubuntu 22.04"
  flavor_name = var.instance_flavour
  key_pair    = openstack_compute_keypair_v2.ssh_keypair.name

  network {
    uuid        = data.terraform_remote_state.vpn_private_network.outputs.private_network_id
    fixed_ip_v4 = local.instance_ip
  }

  security_groups = [data.terraform_remote_state.jenkins_sg.outputs.jenkins_sg]

  user_data = <<-EOF
    #!/bin/bash
    sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
    # Update the package list and upgrade the system
    sudo apt-get update -y
  EOF

}

resource "openstack_compute_floatingip_associate_v2" "vpn_floating_ip_association" {
  floating_ip = openstack_networking_floatingip_v2.microservices_floating_ip.address
  instance_id = openstack_compute_instance_v2.jenkins_instance.id
}

resource "null_resource" "add_key_to_user" {
  depends_on = [openstack_compute_instance_v2.jenkins_instance] # Ensure the instance is created before executing remote-exec provisioner

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ssh_key.private_key_pem
    host        = openstack_networking_floatingip_v2.microservices_floating_ip.address
    port        = var.ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      # Save the public key as a separate file
      "echo '${tls_private_key.ssh_key.public_key_openssh}' > ~/public_key.pem",
    ]
  }
}

resource "null_resource" "configure_ansible_inventory" {
  provisioner "local-exec" {
    command = <<EOT
      ssh-add ssh_key_${replace(var.instance_hostname, ".", "_")}
      echo "[jenkins]" > ${path.module}/../../ansible/inventories/inventory.ini
      echo "jenkins-server ansible_host=${openstack_networking_floatingip_v2.microservices_floating_ip.address} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}/ssh_key_${replace(var.instance_hostname, ".", "_")}" >> ${path.module}/../../ansible/inventories/inventory.ini
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${path.module}/../../ansible/inventories/inventory.ini ${path.module}/../../ansible/playbook.yml
    EOT
  }

  depends_on = [null_resource.add_key_to_user]
}

