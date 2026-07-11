# Создаем единую VPC
resource "yandex_vpc_network" "diploma_vpc" {
  name = "diploma-network"
}

# Публичная подсеть в зоне A (Бастион, Zabbix, Kibana, ALB)
resource "yandex_vpc_subnet" "public_subnet_a" {
  name           = "public-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diploma_vpc.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Публичная подсеть в зоне B (для ALB во второй зоне)
resource "yandex_vpc_subnet" "public_subnet_b" {
  name           = "public-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.diploma_vpc.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

# Приватная подсеть в зоне A (web-1, Elasticsearch)
resource "yandex_vpc_subnet" "private_subnet_a" {
  name           = "private-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diploma_vpc.id
  v4_cidr_blocks = ["192.168.11.0/24"]
  route_table_id = yandex_vpc_route_table.nat_route_table.id
}

# Приватная подсеть в зоне B (web-2)
resource "yandex_vpc_subnet" "private_subnet_b" {
  name           = "private-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.diploma_vpc.id
  v4_cidr_blocks = ["192.168.21.0/24"]
  route_table_id = yandex_vpc_route_table.nat_route_table.id
}

# NAT-шлюз для исходящего интернета в приватных подсетях
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

# Таблица маршрутизации для NAT
resource "yandex_vpc_route_table" "nat_route_table" {
  name       = "nat-route-table"
  network_id = yandex_vpc_network.diploma_vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}