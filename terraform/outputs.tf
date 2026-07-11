
output "bastion_public_ip" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "zabbix_public_ip" {
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}

output "kibana_public_ip" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

output "alb_public_ip" {
  value = yandex_alb_load_balancer.web_alb.listener[0].endpoint[0].address[0].external_ipv4_address
}

output "web_a_ip" {
  value = yandex_compute_instance.web_a.network_interface.0.ip_address
}

output "web_b_ip" {
  value = yandex_compute_instance.web_b.network_interface.0.ip_address
}

output "elastic_ip" {
  value = yandex_compute_instance.elastic.network_interface.0.ip_address
}
