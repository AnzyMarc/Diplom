# ============ Security Group для Бастион-хоста ============
resource "yandex_vpc_security_group" "sg_bastion" {
  name        = "sg-bastion"
  network_id  = yandex_vpc_network.diploma_vpc.id
  description = "Security group for Bastion host"

  ingress {
    protocol       = "TCP"
    description    = "SSH from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Zabbix Agent connections"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 10050
  }

  egress {
    protocol       = "ANY"
    description    = "Outgoing traffic to all network"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ============ Security Group для веб-серверов ============
resource "yandex_vpc_security_group" "sg_web" {
  name        = "sg-web"
  network_id  = yandex_vpc_network.diploma_vpc.id
  description = "Security group for Web servers"

  ingress {
    protocol       = "TCP"
    description    = "HTTP from load balancer"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24"]
    port           = 80
  }

  ingress {
    protocol           = "TCP"
    description        = "Health checks from load balancer"
    predefined_target  = "loadbalancer_healthchecks"
    port               = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH from Bastion"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Zabbix Agent connections"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 10050
  }

  egress {
    protocol       = "ANY"
    description    = "Outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ============ Security Group для Application Load Balancer ============
resource "yandex_vpc_security_group" "sg_alb" {
  name        = "sg-alb"
  network_id  = yandex_vpc_network.diploma_vpc.id
  description = "Security group for ALB"

  ingress {
    protocol       = "TCP"
    description    = "HTTP from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "Load balancer node health checks"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
    port           = 30080
  }

  egress {
    protocol       = "ANY"
    description    = "Outgoing to web servers"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ============ Security Group для Zabbix Server ============
resource "yandex_vpc_security_group" "sg_zabbix" {
  name        = "sg-zabbix"
  network_id  = yandex_vpc_network.diploma_vpc.id
  description = "Security group for Zabbix Server"

  ingress {
    protocol       = "TCP"
    description    = "SSH from Bastion only"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Web interface HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8080
  }

  ingress {
    protocol       = "TCP"
    description    = "Zabbix Agent (active checks)"
    v4_cidr_blocks = ["192.168.0.0/16"]
    port           = 10051
  }

  ingress {
    protocol       = "TCP"
    description    = "Zabbix Agent connections (self-monitoring)"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 10050
  }

  egress {
    protocol       = "ANY"
    description    = "Outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ============ Security Group для Elasticsearch ============
resource "yandex_vpc_security_group" "sg_elastic" {
  name        = "sg-elastic"
  network_id  = yandex_vpc_network.diploma_vpc.id
  description = "Security group for Elasticsearch"

  ingress {
    protocol       = "TCP"
    description    = "Elasticsearch API"
    v4_cidr_blocks = ["192.168.0.0/16"]
    port           = 9200
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH from Bastion"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Zabbix Agent connections"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 10050
  }

  egress {
    protocol       = "ANY"
    description    = "Outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ============ Security Group для Kibana ============
resource "yandex_vpc_security_group" "sg_kibana" {
  name        = "sg-kibana"
  network_id  = yandex_vpc_network.diploma_vpc.id
  description = "Security group for Kibana"

  ingress {
    protocol       = "TCP"
    description    = "SSH from Bastion only"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Kibana Web Interface"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  ingress {
    protocol       = "TCP"
    description    = "Zabbix Agent connections"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 10050
  }

  egress {
    protocol       = "ANY"
    description    = "Outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}