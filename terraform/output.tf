output "ip_address" {
    value = "${module.tf-yc-instance.ip_address}"
} 

output "ip_address_external" {
    value = "${module.tf-yc-instance.ip_address_external}"
}

output "subnet" {
    value = "${module.tf-yc-network.yandex_vpc_subnets[var.zone]}"
}