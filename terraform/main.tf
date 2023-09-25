module "tf-yc-network" {
  source = "./modules/tf-yc-network"
}

module "tf-yc-instance" {
  source = "./modules/tf-yc-instance"

  yc_image_id      = var.image_id
  yc_instance_zone = var.zone
  yc_subnet_id     = module.tf-yc-network.yandex_vpc_subnets[var.zone].subnet_id
}