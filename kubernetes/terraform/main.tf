terraform {
    required_providers {
        yandex = {
        source  = "yandex-cloud/yandex"
        version = ">= 0.87.0"
        }
    }

    # Описание бэкенда хранения состояния
    # backend "s3" {
    #     endpoint   = "storage.yandexcloud.net"
    #     bucket     = "terraform-state-momo"
    #     region     = "ru-central1"
    #     key        = "terraform.tfstate"

    #     skip_region_validation      = true
    #     skip_credentials_validation = true
    # }
}

locals {
    cloud_id    = "b1g79hcd88obovlnq7v7"
    folder_id   = "b1gn93d5j7l9kl73n2nm"
    k8s_version = "1.22"
    sa_name     = "momoaccount"
}

provider "yandex" {
    cloud_id  = local.cloud_id
    folder_id = local.folder_id
    zone      = "ru-central1-a"
}

resource "yandex_kubernetes_cluster" "momo_k8s_kluster" {
    network_id = yandex_vpc_network.momonet.id
    master {
        zonal {
            zone      = yandex_vpc_subnet.momosubnet.zone
            subnet_id = yandex_vpc_subnet.momosubnet.id
        }
        
        public_ip = true

        security_group_ids = [
            yandex_vpc_security_group.k8s-main-sg.id,
            yandex_vpc_security_group.k8s-master-whitelist.id
        ]
    }
    service_account_id      = yandex_iam_service_account.momoaccount.id
    node_service_account_id = yandex_iam_service_account.momoaccount.id
    depends_on = [
        yandex_resourcemanager_folder_iam_member.editor,
        yandex_resourcemanager_folder_iam_member.images-puller,
        yandex_resourcemanager_folder_iam_member.vpc-public-admin
    ]
}

resource "yandex_kubernetes_node_group" "momo_k8s_nodes" {
    cluster_id = yandex_kubernetes_cluster.momo_k8s_kluster.id
    name       = "momok8snodes"
    
    instance_template {
        container_runtime {
            type = "containerd"
        }
        network_interface {
            nat = true
            subnet_ids         = [yandex_vpc_subnet.momosubnet.id]
            security_group_ids = [
                yandex_vpc_security_group.k8s-main-sg.id
            ]
        }
    }

    scale_policy {
        fixed_scale {
            size = 1
        }
    }
}

resource "yandex_vpc_network" "momonet" { name = "momonet" }

resource "yandex_vpc_subnet" "momosubnet" {
    v4_cidr_blocks = ["10.1.0.0/16"]
    zone           = "ru-central1-a"
    network_id     = yandex_vpc_network.momonet.id
}

resource "yandex_iam_service_account" "momoaccount" {
    name        = local.sa_name
    description = "K8S zonal service account"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
    # Сервисному аккаунту назначается роль "editor".
    folder_id = local.folder_id
    role      = "editor"
    member    = "serviceAccount:${yandex_iam_service_account.momoaccount.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
    # Сервисному аккаунту назначается роль "container-registry.images.puller".
    folder_id = local.folder_id
    role      = "container-registry.images.puller"
    member    = "serviceAccount:${yandex_iam_service_account.momoaccount.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
    # Сервисному аккаунту назначается роль vpc.publicAdmin для публичного доступа
    folder_id = local.folder_id
    role      = "vpc.publicAdmin"
    member    = "serviceAccount:${yandex_iam_service_account.momoaccount.id}"
}

resource "yandex_vpc_security_group" "k8s-main-sg" {
    name        = "k8s-main-sg"
    description = "Правила группы обеспечивают базовую работоспособность кластера. Примените ее к кластеру и группам узлов."
    network_id  = yandex_vpc_network.momonet.id
        ingress {
        protocol          = "TCP"
        description       = "Правило разрешает проверки доступности с диапазона адресов балансировщика нагрузки. Нужно для работы отказоустойчивого кластера и сервисов балансировщика."
        predefined_target = "loadbalancer_healthchecks"
        from_port         = 0
        to_port           = 65535
    }
    ingress {
        protocol          = "ANY"
        description       = "Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности."
        predefined_target = "self_security_group"
        from_port         = 0
        to_port           = 65535
    }
    ingress {
        protocol       = "ANY"
        description    = "Правило разрешает взаимодействие под-под и сервис-сервис. Укажите подсети вашего кластера и сервисов."
        v4_cidr_blocks = ["10.1.0.0/16"]
        from_port      = 0
        to_port        = 65535
    }
    ingress {
        protocol       = "ICMP"
        description    = "Правило разрешает отладочные ICMP-пакеты из внутренних подсетей."
        v4_cidr_blocks = ["10.1.0.0/16"]
    }
    egress {
        protocol       = "ANY"
        description    = "Правило разрешает весь исходящий трафик. Узлы могут связаться с Yandex Container Registry, Object Storage, Docker Hub и т. д."
        v4_cidr_blocks = ["0.0.0.0/0"]
        from_port      = 0
        to_port        = 65535
    }
}

resource "yandex_vpc_security_group" "k8s-master-whitelist" {
    name        = "k8s-master-whitelist"
    description = "Правила группы разрешают доступ к API Kubernetes из интернета. Примените правила только к кластеру."
    network_id  = yandex_vpc_network.momonet.id

    ingress {
        protocol       = "TCP"
        description    = "Правило разрешает подключение к API Kubernetes через порт 6443."
        port           = 6443
    }

    ingress {
        protocol       = "TCP"
        description    = "Правило разрешает подключение к API Kubernetes через порт 443."
        port           = 443
    }
}