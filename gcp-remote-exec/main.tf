resource "google_compute_firewall" "allow-http-ssh" {
  name    = "allow-http-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-http-ssh"]
}


resource "google_compute_instance" "test-machine" {
  name         = "test-machine"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = google_compute_firewall.allow-http-ssh.target_tags

  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"
  }
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
      host        = google_compute_instance.test-machine.network_interface[0].access_config[0].nat_ip
      private_key = file(var.privatekeypath)
    }
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
  }

  provisioner "local-exec" {
    command = "chrome ${google_compute_instance.test-machine.network_interface[0].access_config[0].nat_ip}"
  }

}
