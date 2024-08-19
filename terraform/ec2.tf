# resource "aws_instance" "vault" {
#   ami                         = "ami-0be48b687295f8bd6" # ubuntu 22.04
#   instance_type               = "t3.micro"
#   availability_zone           = var.ec2_network.availability_zone
#   subnet_id                   = var.ec2_network.subnet_id
#   key_name                    = var.ec2_network.key_name
#   associate_public_ip_address = false
#   source_dest_check           = true
#   vpc_security_group_ids      = [aws_security_group.fabric["vault"].id]
#   root_block_device {
#     delete_on_termination = false
#     volume_size           = 20
#     volume_type           = "gp2"
#   }

#   tags = {
#     Name = "vault"
#   }
# }


resource "aws_instance" "fabric" {
  for_each                    = var.fabric
  ami                         = "ami-0be48b687295f8bd6" # ubuntu 22.04
  instance_type               = "t3.micro"
  user_data                   = <<-EOF
                                #!/bin/bash
                                # echo "your-hostname" > /etc/hostname
                                hostnamectl set-hostname ${each.key}
                                # Update /etc/hosts to map the new hostname to the localhost IP
                                echo "127.0.0.1  ${each.key}" >> /etc/hosts
                                # Add Docker's official GPG key:
                                apt-get update
                                apt-get install -y ca-certificates curl
                                install -m 0755 -d /etc/apt/keyrings
                                curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
                                chmod a+r /etc/apt/keyrings/docker.asc
                                # Add the repository to Apt sources:
                                echo \
                                  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
                                  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                                  tee /etc/apt/sources.list.d/docker.list > /dev/null
                                apt-get update
                                # apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                                VERSION_STRING=5:23.0.0-1~ubuntu.22.04~jammy
                                sudo apt-get install -y docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin
                                docker run hello-world
                                cd /home/ubuntu
                                curl -o /home/ubuntu/install-fabric.sh -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
                                /home/ubuntu/install-fabric.sh --fabric-version 2.5.9 binary
                                git clone https://github.com/hyperledger/fabric-samples.git /home/ubuntu/fabric-samples
                                ln -s /home/ubuntu/config/ /home/ubuntu/fabric-samples/config
                                EOF
  availability_zone           = var.ec2_network.availability_zone
  subnet_id                   = var.ec2_network.subnet_id
  key_name                    = var.ec2_network.key_name
  associate_public_ip_address = false
  source_dest_check           = true
  vpc_security_group_ids      = [aws_security_group.fabric["fabric"].id]
  root_block_device {
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp2"
  }

  tags = {
    Name = "${each.key}"
  }
}
