variable "yc_token" {
  type      = string
  sensitive = true
}

variable "subnet_id" {
  type      = string
  sensitive = true
}

variable folder_id {
  type      = string
  sensitive = true
}

source "yandex" "debian_docker" {
  disk_type           = "network-hdd"
  disk_size_gb        = 10
  folder_id           = "${var.folder_id}"
  image_description   = "my custom debian with docker"
  image_name          = "debian-11-docker"
  source_image_family = "debian-11"
  ssh_username        = "debian"
  subnet_id           = "${var.subnet_id}"
  token               = "${var.yc_token}"
  use_ipv4_nat        = true
  zone                = "ru-central1-d"
  instance_mem_gb              = 2
  instance_cores               = 2
  instance_core_fraction       = 5

}

build {
  sources = ["source.yandex.debian_docker"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y curl tmux htop net-tools ca-certificates",
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh ./get-docker.sh",
    ]
  }

}
