resource "google_compute_instance" "test-machine" {
    name         = "test-machine"
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
            host        = google_compute_instance.test-machine.network_interface[0].access_config[0].nat_ip
            private_key = file(var.privatekeypath)
        }
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y nginx"
        ]
    }
      
}
