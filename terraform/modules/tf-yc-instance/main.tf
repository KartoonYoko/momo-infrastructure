resource "yandex_compute_instance" "vm-1" {
  name = var.yc_instance_name

  zone = var.yc_instance_zone
  platform_id = var.yc_platform_id
  
  scheduling_policy {
    preemptible = var.yc_scheduling_policy_preemptible
  }

  # Конфигурация ресурсов:
  # количество процессоров и оперативной памяти
  resources {
    cores  = 2
    memory = 2
  }

  # Загрузочный диск:
  # здесь указывается образ операционной системы
  # для новой виртуальной машины
  boot_disk {
    initialize_params {
      image_id = var.yc_image_id
      # Размер диска ВМ
      size = 50
    }
  }

  # Сетевой интерфейс:
  # нужно указать идентификатор подсети, к которой будет подключена ВМ
  network_interface {
    subnet_id = var.yc_subnet_id
    nat       = true
  }

  # Метаданные машины:
  # здесь можно указать скрипт, который запустится при создании ВМ
  # или список SSH-ключей для доступа на ВМ
  metadata = {
    # ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    # user-data = "${file("./meta.txt")}"
    user-data = file("${path.module}/cloud_config.yaml")
  }
}