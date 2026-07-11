# ============ Bastion Host ============
resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v3"
  zone        = var.zone_a

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_subnet_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg_bastion.id]
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file(var.public_key_path)}"
  }

  allow_stopping_for_update = true

  scheduling_policy {
    preemptible = false
  }
}