resource "aws_security_group" "cluster" {
  name   = var.cluster_name
  vpc_id = var.existing_vpc_id != "" ? var.existing_vpc_id : join("", aws_vpc.vpc.*.id)

  tags = {
    Name = "${var.cluster_name}-cluster"
    ROLE = var.role_tag_value
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster.id
  description       = "SSH access"
}

resource "aws_security_group_rule" "installer_61008" {
  type              = "ingress"
  from_port         = 61008
  to_port           = 61010
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Installer agent ports"
}

resource "aws_security_group_rule" "installer_61022" {
  type              = "ingress"
  from_port         = 61022
  to_port           = 61024
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Installer agent ports"
}

resource "aws_security_group_rule" "bandwidth" {
  type              = "ingress"
  from_port         = 4242
  to_port           = 4242
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Bandwidth checker utility"
}

// Internal cluster DNS
resource "aws_security_group_rule" "dns_udp" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Internal cluster DNS"
}

resource "aws_security_group_rule" "dns_tcp" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Internal cluster DNS"
}

resource "aws_security_group_rule" "overlay" {
  type              = "ingress"
  from_port         = 8472
  to_port           = 8472
  protocol          = "udp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Overlay network"
}

resource "aws_security_group_rule" "serf_7496" {
  type              = "ingress"
  from_port         = 7496
  to_port           = 7496
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Serf (Health check agents) peer to peer"
}

resource "aws_security_group_rule" "serf_7496_udp" {
  type              = "ingress"
  from_port         = 7496
  to_port           = 7496
  protocol          = "udp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Serf (Health check agents) peer to peer"
}

resource "aws_security_group_rule" "serf_7373" {
  type              = "ingress"
  from_port         = 7373
  to_port           = 7373
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Serf (Health check agents) peer to peer"
}

// Cluster status gRPC API
resource "aws_security_group_rule" "cluster_status" {
  type              = "ingress"
  from_port         = 7575
  to_port           = 7575
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Cluster status gRPC API"
}

resource "aws_security_group_rule" "etcd_2379" {
  type              = "ingress"
  from_port         = 2379
  to_port           = 2380
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Etcd server communications"
}

resource "aws_security_group_rule" "etcd_4001" {
  type              = "ingress"
  from_port         = 4001
  to_port           = 4001
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Etcd server communications"
}

// Etcd server communications
resource "aws_security_group_rule" "etcd_7001" {
  type              = "ingress"
  from_port         = 7001
  to_port           = 7001
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Etcd server communications"
}

// Kubernetes API Server
resource "aws_security_group_rule" "kubernetes_api" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Kubernetes API server"
}

// Kubernetes API Server
resource "aws_security_group_rule" "kubernetes_api_external" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster.id
  count             = length(var.kubernetes_api_cidr_blocks) == 0 ? 0 : 1
  cidr_blocks       = var.kubernetes_api_cidr_blocks
  description       = "Kubernetes API server (ext)"
}

resource "aws_security_group_rule" "k8s_components" {
  type              = "ingress"
  from_port         = 10248
  to_port           = 10250
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Kubernetes components"
}

resource "aws_security_group_rule" "k8s_components_2" {
  type              = "ingress"
  from_port         = 10255
  to_port           = 10255
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Kubernetes components"
}

resource "aws_security_group_rule" "docker_registry" {
  type              = "ingress"
  from_port         = 5000
  to_port           = 5000
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Internal Docker registry"
}

resource "aws_security_group_rule" "internal_teleport" {
  type              = "ingress"
  from_port         = 3022
  to_port           = 3025
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Teleport internal SSH control panel"
}

resource "aws_security_group_rule" "internal_telekube" {
  type              = "ingress"
  from_port         = 3008
  to_port           = 3012
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "Internal Telekube services"
}

resource "aws_security_group_rule" "ops_center" {
  type              = "ingress"
  from_port         = 32009
  to_port           = 32009
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "OpsCenter UI"
}

resource "aws_security_group_rule" "ops_center_external" {
  type              = "ingress"
  from_port         = 32009
  to_port           = 32009
  protocol          = "tcp"
  cidr_blocks       = var.ops_center_cidr_blocks
  count             = length(var.ops_center_cidr_blocks) == 0 ? 0 : 1
  security_group_id = aws_security_group.cluster.id
  description       = "OpsCenter UI"
}

resource "aws_security_group_rule" "ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster.id
  description       = "HTTPS ingress"
}

resource "aws_security_group_rule" "rtf_agent" {
  type              = "ingress"
  from_port         = 30945
  to_port           = 30945
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
  description       = "RTF Agent API"
}

