resource "aws_instance" "k3s-master-1" {

  ami           = var.ami
  instance_type = var.type
  tags = {
    Name = "K3s Master 1"
  }
  key_name        = var.key_name
  security_groups = var.security_groups
  root_block_device {
    volume_size = var.root_block_device
  }
}

resource "aws_instance" "k3s-master-2" {

  ami           = var.ami
  instance_type = var.type
  tags = {
    Name = "K3s Master 2"
  }
  key_name        = var.key_name
  security_groups = var.security_groups
  root_block_device {
    volume_size = var.root_block_device
  }
}


resource "null_resource" "k3s-master1-setup" {

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./credentials/ec2-key.pem")
    host        = aws_instance.k3s-master-1.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install wireguard -y",
      "sudo curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=\"v1.25.5+k3s1\" sh -s - server --token=dfXagzaueZM8Ye --cluster-init --cluster-cidr 10.10.0.0/16 --service-cidr 10.40.0.0/16 --tls-san ${aws_instance.k3s-master-1.public_ip} --tls-san ${aws_instance.k3s-master-2.public_ip}",

    ]
  }
}

resource "null_resource" "k3s-master2-setup" {
  depends_on = [
    null_resource.k3s-master1-setup,
  ]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./credentials/ec2-key.pem")
    host        = aws_instance.k3s-master-2.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install wireguard -y",
      "sudo curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=\"v1.25.5+k3s1\" sh -s - server --server https://${aws_instance.k3s-master-1.private_ip}:6443  --token=dfXagzaueZM8Ye --cluster-cidr 10.10.0.0/16 --service-cidr 10.40.0.0/16 --tls-san ${aws_instance.k3s-master-1.public_ip} --tls-san ${aws_instance.k3s-master-2.public_ip}"

    ]
  }
}

resource "aws_instance" "k3s-worker-1" {

  ami           = var.ami
  instance_type = var.type
  tags = {
    Name = "K3s Worker 1"
  }
  key_name        = var.key_name
  security_groups = var.security_groups
  root_block_device {
    volume_size = var.root_block_device
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./credentials/ec2-key.pem")
      host        = aws_instance.k3s-worker-1.public_ip

    }

    inline = [
      "sudo apt update",
      "sudo apt install wireguard -y",
      "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=\"v1.25.5+k3s1\" sh -s - agent --server https://${aws_instance.k3s-master-1.private_ip}:6443 --token=dfXagzaueZM8Ye"
    ]
  }
}

resource "aws_instance" "k3s-worker-2" {

  ami           = var.ami
  instance_type = var.type
  tags = {
    Name = "K3s Worker 2"
  }
  key_name        = var.key_name
  security_groups = var.security_groups
  root_block_device {
    volume_size = var.root_block_device
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./credentials/ec2-key.pem")
      host        = aws_instance.k3s-worker-2.public_ip
    }

    inline = [
      "sudo apt update",
      "sudo apt install wireguard -y",
      "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=\"v1.25.5+k3s1\" sh -s - agent --server https://${aws_instance.k3s-master-1.private_ip}:6443 --token=dfXagzaueZM8Ye"
    ]
  }
}