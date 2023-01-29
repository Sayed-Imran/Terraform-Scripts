resource "google_compute_instance" "k3s-master-1" {

  name         = "k3s-master-1"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["allow-all"]
  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  network_interface {
    network = "default"
    access_config {

    }
  }

}

resource "google_compute_instance" "k3s-master-2" {

  name         = "k3s-master-2"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["allow-all"]
  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  network_interface {
    network = "default"
    access_config {

    }
  }
}


resource "null_resource" "k3s-master1-setup" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.user
      host        = google_compute_instance.k3s-master-1.network_interface[0].access_config[0].nat_ip
      private_key = file(var.privatekeypath)
    }
    inline = [
      "sudo apt-get update",
      "sudo apt install wireguard -y",
      "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=\"v1.25.5+k3s1\" sh -s - server --token=dfXagzaueZM8Ye --cluster-init --cluster-cidr 10.20.0.0/16 --service-cidr 10.50.0.0/16 --tls-san ${google_compute_instance.k3s-master-1.network_interface[0].access_config[0].nat_ip} --tls-san ${google_compute_instance.k3s-master-2.network_interface[0].access_config[0].nat_ip}",
      "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml",
      "echo $KUBECONFIG",
    ]
  }
}

resource "null_resource" "k3s-master2-setup" {
  depends_on = [null_resource.k3s-master1-setup]
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.user
      host        = google_compute_instance.k3s-master-2.network_interface[0].access_config[0].nat_ip
      private_key = file(var.privatekeypath)
    }
    inline = [
      "sudo apt-get update",
      "sudo apt install wireguard -y",
      "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=\"v1.25.5+k3s1\" sh -s - server --server https://${google_compute_instance.k3s-master-1.network_interface[0].network_ip}:6443  --token=dfXagzaueZM8Ye --cluster-cidr 10.20.0.0/16 --service-cidr 10.50.0.0/16 --tls-san ${google_compute_instance.k3s-master-1.network_interface[0].access_config[0].nat_ip} --tls-san ${google_compute_instance.k3s-master-2.network_interface[0].access_config[0].nat_ip}"
    ]
  }

}

resource "google_compute_instance" "k3s-worker-1" {
  depends_on = [
    null_resource.k3s-master1-setup,
    null_resource.k3s-master2-setup
  ]
  name         = "k3s-worker-1"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["allow-all"]
  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  network_interface {
    network = "default"
    access_config {

    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.user
      host        = google_compute_instance.k3s-worker-1.network_interface[0].access_config[0].nat_ip
      private_key = file(var.privatekeypath)
    }

    inline = [
      "sudo apt-get update",
      "sudo apt install wireguard -y",
      "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=\"v1.25.5+k3s1\" sh -s - agent --server https://${google_compute_instance.k3s-master-1.network_interface[0].network_ip}:6443 --token=dfXagzaueZM8Ye"
    ]

  }

}

resource "google_compute_instance" "k3s-worker-2" {
  depends_on = [
    null_resource.k3s-master1-setup,
    null_resource.k3s-master2-setup
  ]
  name         = "k3s-worker-2"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["allow-all"]
  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  network_interface {
    network = "default"
    access_config {

    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.user
      host        = google_compute_instance.k3s-worker-2.network_interface[0].access_config[0].nat_ip
      private_key = file(var.privatekeypath)
    }

    inline = [
      "sudo apt-get update",
      "sudo apt install wireguard -y",
      "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=\"v1.25.5+k3s1\" sh -s - agent --server https://${google_compute_instance.k3s-master-1.network_interface[0].network_ip}:6443 --token=dfXagzaueZM8Ye"
    ]

  }

}
