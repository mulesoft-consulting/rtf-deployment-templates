provider "aws" {
}

variable "key_pair" {
  default = ""
}

variable "cluster_name" {
  default = "runtime-fabric"
}

variable "controllers" {
  default = 1
}

variable "workers" {
  default = 2
}

variable "inbound_traffic_controllers" {
  default = 0
}

variable "installer_url" {
  default = ""
}

variable "ami_name" {
  default = "RHEL-7.7_HVM_GA-20190723-x86_64-1-Hourly2-GP2"
}

variable "ami_owner_id" {
  default = "309956199498" # RedHat (https://access.redhat.com/articles/2962171)
}

variable "instance_type_controller" {
  default = "m5.large"
}

variable "instance_type_worker" {
  default = "r5.large"
}

variable "instance_type_inbound_traffic_controller" {
  default = "m4.large"
}

variable "cluster_token" {
  default = ""
}

variable "role_tag_value" {
  default = "RuntimeFabric-terraform"
}

variable "vpc_cidr" {
  default = "172.31.0.0/16"
}

variable "activation_data" {
  default = ""
}

variable "anypoint_org_id" {
  default = ""
}

variable "anypoint_region" {
  default = "us-east-1"
}

variable "anypoint_endpoint" {
  default = "https://anypoint.mulesoft.com"
}

variable "anypoint_token" {
  default = ""
}

variable "mule_license" {
  default = ""
}

variable "enable_public_ips" {
  default = false
}

variable "existing_vpc_id" {
  default = ""
}

variable "existing_subnet_ids" {
  type = list(string)
  default = []
}

variable "enable_elastic_ips" {
  default = false
}

variable "enable_loadbalancer" {
  default = false
}

variable "enable_nat_gateways" {
  default = false
}

variable "kubernetes_api_cidr_blocks" {
  type = list(string)
  default = []
}

variable "ops_center_cidr_blocks" {
  type = list(string)
  default = []
}

variable "pod_network_cidr_block" {
  default = "10.244.0.0/16"
}

variable "service_cidr_block" {
  default = "10.100.0.0/16"
}

variable "http_proxy" {
  default = ""
}

variable "no_proxy" {
  default = ""
}

variable "monitoring_proxy" {
  default = ""
}

variable "egress_cidr_blocks" {
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "ntp_egress_cidr_blocks" {
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "service_uid" {
  default = ""
}

variable "service_gid" {
  default = ""
}

variable "agent_url" {
  default = ""
}

locals {
  root_volume_type = "gp2"
  root_volume_size = "90"

  gravity_volume_type                            = "gp2"
  gravity_volume_size                            = "250"
  gravity_volume_size_inbound_traffic_controller = "50"
  gravity_volume_device_name                     = "/dev/xvdb"

  etcd_volume_type = "io1"
  etcd_volume_iops = "3000"
  etcd_volume_size = "60"
  etcd_device_name = "/dev/xvdc"

  volume_delete_on_termination = true

  lb_subnet_mappings = concat(var.existing_subnet_ids, aws_instance.installer_node.*.subnet_id, aws_instance.controller_node.*.subnet_id)
}

resource "random_string" "cluster_token" {
  length  = 16
  special = false
}

data "template_file" "installer_env" {
  template = file("${path.module}/installer_env.sh")

  vars = {
    cluster_name     = var.cluster_name
    cluster_token    = var.cluster_token != "" ? var.cluster_token : random_string.cluster_token.result
    activation_data  = var.activation_data
    installer_url    = var.installer_url
    org_id           = var.anypoint_org_id
    region           = var.anypoint_region
    endpoint         = var.anypoint_endpoint
    auth_token       = var.anypoint_token
    mule_license     = var.mule_license
    http_proxy       = var.http_proxy
    no_proxy         = var.no_proxy
    monitoring_proxy = var.monitoring_proxy
    service_uid      = var.service_uid
    service_gid      = var.service_gid
    agent_url        = var.agent_url
    pod_network_cidr_block = var.pod_network_cidr_block
    service_cidr_block     = var.service_cidr_block
  }
}

data "template_file" "controller_env" {
  template = file("${path.module}/controller_env.sh")

  vars = {
    installer_ip     = aws_instance.installer_node[0].private_ip
    cluster_name     = var.cluster_name
    cluster_token    = var.cluster_token != "" ? var.cluster_token : random_string.cluster_token.result
    http_proxy       = var.http_proxy
    no_proxy         = var.no_proxy
    monitoring_proxy = var.monitoring_proxy
    service_uid      = var.service_uid
    service_gid      = var.service_gid
  }
}

data "template_file" "worker_env" {
  template = file("${path.module}/worker_env.sh")

  vars = {
    installer_ip  = aws_instance.installer_node[0].private_ip
    cluster_name  = var.cluster_name
    cluster_token = var.cluster_token != "" ? var.cluster_token : random_string.cluster_token.result
    http_proxy    = var.http_proxy
    no_proxy      = var.no_proxy
    service_uid   = var.service_uid
    service_gid   = var.service_gid
  }
}

data "template_file" "inbound_traffic_controller_env" {
  template = file("${path.module}/inbound_traffic_controller_env.sh")

  vars = {
    installer_ip  = aws_instance.installer_node[0].private_ip
    cluster_name  = var.cluster_name
    cluster_token = var.cluster_token != "" ? var.cluster_token : random_string.cluster_token.result
  }
}

data "template_cloudinit_config" "installer" {
  part {
    filename     = "envvars.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.installer_env.rendered
  }

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/../scripts/init.sh")
  }
}

data "template_cloudinit_config" "controller" {
  part {
    filename     = "envvars.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.controller_env.rendered
  }

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/../scripts/init.sh")
  }
}

data "template_cloudinit_config" "worker" {
  part {
    filename     = "envvars.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.worker_env.rendered
  }

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/../scripts/init.sh")
  }
}

data "template_cloudinit_config" "inbound_traffic_controller" {
  part {
    filename     = "envvars.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.inbound_traffic_controller_env.rendered
  }

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/../scripts/init.sh")
  }
}

output "controller_private_ips" {
  value = join(
    " ",
    aws_instance.installer_node.*.private_ip,
    aws_instance.controller_node.*.private_ip,
  )
}

output "worker_private_ips" {
  value = join(" ", aws_instance.worker_node.*.private_ip)
}

output "controller_public_ips" {
  value = join(
    " ",
    aws_instance.installer_node.*.public_ip,
    aws_instance.controller_node.*.public_ip,
  )
}

output "worker_public_ips" {
  value = join(" ", aws_instance.worker_node.*.public_ip)
}

output "controller_elastic_ips" {
  value = join(
    " ",
    aws_eip.installer_ip.*.public_ip,
    aws_eip.controller_ip.*.public_ip,
  )
}

output "inbound_traffic_controller_private_ips" {
  value = join(" ", aws_instance.inbound_traffic_controller.*.private_ip)
}

output "inbound_traffic_controller_public_ips" {
  value = join(" ", aws_instance.inbound_traffic_controller.*.public_ip)
}

output "loadbalancer_dns_name" {
  value = join(" ", aws_lb.load_balancer.*.dns_name)
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  count                = var.existing_vpc_id != "" ? 0 : 1

  tags = {
    Name = "${var.cluster_name}-vpc"
    ROLE = var.role_tag_value
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc[0].id
  cidr_block = cidrsubnet(
    var.vpc_cidr,
    24 - replace(var.vpc_cidr, "/[^/]*[/]/", ""),
    count.index,
  )
  map_public_ip_on_launch = var.enable_public_ips
  count                   = var.existing_vpc_id != "" ? 0 : length(data.aws_availability_zones.available.names)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "${var.cluster_name}-subnet"
    ROLE = var.role_tag_value
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc[0].id
  count  = var.existing_vpc_id != "" ? 0 : 1

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw[0].id
  }

  tags = {
    Name = "${var.cluster_name}-rt"
    ROLE = var.role_tag_value
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.vpc[0].id
  count          = var.existing_vpc_id != "" ? 0 : 1
  route_table_id = aws_route_table.rt[0].id
}

resource "aws_route_table_association" "rta" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.rt[0].id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc[0].id
  count  = var.existing_vpc_id != "" ? 0 : 1

  tags = {
    Name = "${var.cluster_name}-gw"
    ROLE = var.role_tag_value
  }
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateways == "true" ? length(data.aws_availability_zones.available.names) : 0
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "ngw" {
  count         = var.enable_nat_gateways == "true" ? length(data.aws_availability_zones.available.names) : 0
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_subnet.public]

  tags = {
    Name = "${var.cluster_name}-ngw"
    ROLE = var.role_tag_value
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "installer_node" {
  ami                         = data.aws_ami.nodes.id
  instance_type               = var.instance_type_controller
  associate_public_ip_address = var.enable_public_ips
  source_dest_check           = false
  ebs_optimized               = true
  vpc_security_group_ids      = [aws_security_group.cluster.id]
  subnet_id                   = element(concat(var.existing_subnet_ids, aws_subnet.public.*.id), 0)
  key_name                    = var.key_pair
  count                       = "1"

  tags = {
    Name = "${var.cluster_name}-controller"
    ROLE = var.role_tag_value
  }

  volume_tags = {
    Name = "${var.cluster_name}-volume"
    ROLE = var.role_tag_value
  }

  user_data = data.template_cloudinit_config.installer.rendered

  # OS
  # /var/lib/gravity device
  # /var/lib/data device
  root_block_device {
    volume_type           = local.root_volume_type
    volume_size           = local.root_volume_size
    delete_on_termination = local.volume_delete_on_termination
  }

  # gravity/docker data device
  ebs_block_device {
    volume_type           = local.gravity_volume_type
    volume_size           = local.gravity_volume_size
    device_name           = local.gravity_volume_device_name
    delete_on_termination = local.volume_delete_on_termination
  }

  # etcd device
  ebs_block_device {
    volume_type           = local.etcd_volume_type
    iops                  = local.etcd_volume_iops
    volume_size           = local.etcd_volume_size
    device_name           = local.etcd_device_name
    delete_on_termination = local.volume_delete_on_termination
  }
}

resource "aws_instance" "controller_node" {
  ami                         = data.aws_ami.nodes.id
  instance_type               = var.instance_type_controller
  associate_public_ip_address = var.enable_public_ips
  source_dest_check           = false
  ebs_optimized               = true
  vpc_security_group_ids      = [aws_security_group.cluster.id]

  subnet_id = element(
    concat(var.existing_subnet_ids, aws_subnet.public.*.id),
    count.index + 1,
  )

  key_name = var.key_pair
  count    = var.controllers - 1

  tags = {
    Name = "${var.cluster_name}-controller-${count.index}"
    ROLE = var.role_tag_value
  }

  volume_tags = {
    Name = "${var.cluster_name}-volume"
    ROLE = var.role_tag_value
  }

  user_data = data.template_cloudinit_config.controller.rendered

  # OS
  # /var/lib/gravity device
  # /var/lib/data device
  root_block_device {
    volume_type           = local.root_volume_type
    volume_size           = local.root_volume_size
    delete_on_termination = local.volume_delete_on_termination
  }

  # gravity/docker data device
  ebs_block_device {
    volume_type           = local.gravity_volume_type
    volume_size           = local.gravity_volume_size
    device_name           = local.gravity_volume_device_name
    delete_on_termination = local.volume_delete_on_termination
  }

  # etcd device
  ebs_block_device {
    volume_type           = local.etcd_volume_type
    iops                  = local.etcd_volume_iops
    volume_size           = local.etcd_volume_size
    device_name           = local.etcd_device_name
    delete_on_termination = local.volume_delete_on_termination
  }
}

resource "aws_eip" "installer_ip" {
  vpc        = true
  instance   = element(aws_instance.installer_node.*.id, count.index)
  depends_on = [aws_internet_gateway.gw]
  count      = var.enable_elastic_ips == "true" ? 1 : 0

  tags = {
    Name = "${var.cluster_name}-controller-${count.index}"
  }
}

resource "aws_eip" "controller_ip" {
  vpc        = true
  instance   = element(aws_instance.controller_node.*.id, count.index)
  depends_on = [aws_internet_gateway.gw]
  count      = var.enable_elastic_ips == "true" ? var.controllers - 1 : 0

  tags = {
    Name = "${var.cluster_name}-controller-${count.index}"
  }
}

resource "aws_instance" "worker_node" {
  ami                         = data.aws_ami.nodes.id
  instance_type               = var.instance_type_worker
  associate_public_ip_address = var.enable_public_ips
  source_dest_check           = false
  ebs_optimized               = true
  vpc_security_group_ids      = [aws_security_group.cluster.id]
  subnet_id = element(
    concat(var.existing_subnet_ids, aws_subnet.public.*.id),
    count.index,
  )
  key_name = var.key_pair
  count    = var.workers

  tags = {
    Name = "${var.cluster_name}-worker-${count.index}"
    ROLE = var.role_tag_value
  }

  volume_tags = {
    Name = "${var.cluster_name}-volume"
    ROLE = var.role_tag_value
  }

  user_data = data.template_cloudinit_config.worker.rendered

  # OS
  # /var/lib/gravity device
  # /var/lib/data device
  root_block_device {
    volume_type           = local.root_volume_type
    volume_size           = local.root_volume_size
    delete_on_termination = local.volume_delete_on_termination
  }

  # gravity/docker data device
  ebs_block_device {
    volume_type           = local.gravity_volume_type
    volume_size           = local.gravity_volume_size
    device_name           = local.gravity_volume_device_name
    delete_on_termination = local.volume_delete_on_termination
  }
}

resource "aws_instance" "inbound_traffic_controller" {
  ami                         = data.aws_ami.nodes.id
  instance_type               = var.instance_type_inbound_traffic_controller
  associate_public_ip_address = var.enable_public_ips
  source_dest_check           = false
  ebs_optimized               = true
  vpc_security_group_ids      = [aws_security_group.cluster.id]
  subnet_id = element(
    concat(var.existing_subnet_ids, aws_subnet.public.*.id),
    count.index,
  )
  key_name = var.key_pair
  count    = var.inbound_traffic_controllers

  tags = {
    Name = "${var.cluster_name}-inbound_traffic-${count.index}"
    ROLE = var.role_tag_value
  }

  volume_tags = {
    Name = "${var.cluster_name}-volume"
    ROLE = var.role_tag_value
  }

  user_data = data.template_cloudinit_config.inbound_traffic_controller.rendered

  # OS
  # /var/lib/gravity device
  # /var/lib/data device
  root_block_device {
    volume_type           = local.root_volume_type
    volume_size           = local.root_volume_size
    delete_on_termination = local.volume_delete_on_termination
  }

  # gravity/docker data device
  ebs_block_device {
    volume_type           = local.gravity_volume_type
    volume_size           = local.gravity_volume_size_inbound_traffic_controller
    device_name           = local.gravity_volume_device_name
    delete_on_termination = local.volume_delete_on_termination
  }
}

data "aws_ami" "nodes" {
  owners      = [var.ami_owner_id]
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name]
  }
}

data "aws_availability_zones" "available" {
}

resource "aws_lb" "load_balancer" {
  name  = "${var.cluster_name}-lb"
  count = var.enable_loadbalancer == "true" ? 1 : 0

  load_balancer_type               = "network"
  internal                         = false
  enable_cross_zone_load_balancing = true

  dynamic "subnet_mapping" {
    for_each = local.lb_subnet_mappings

    content {
      subnet_id = subnet_mapping.value
    }
  }

  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "${var.cluster_name}-lb"
  }
}

resource "aws_lb_listener" "load_balancer" {
  load_balancer_arn = aws_lb.load_balancer[0].arn
  protocol          = "TCP"
  port              = "443"
  count             = var.enable_loadbalancer == "true" ? 1 : 0

  default_action {
    target_group_arn = aws_lb_target_group.load_balancer[0].arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "load_balancer" {
  name     = "${var.cluster_name}-lb-target-group"
  protocol = "TCP"
  port     = 443
  vpc_id   = var.existing_vpc_id != "" ? var.existing_vpc_id : aws_vpc.vpc[0].id
  count    = var.enable_loadbalancer == "true" ? 1 : 0

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    port                = 443
    protocol            = "TCP"
  }
}

resource "aws_lb_target_group_attachment" "installer" {
  target_group_arn = aws_lb_target_group.load_balancer[0].arn
  target_id        = aws_instance.installer_node[0].id
  port             = 443
  count            = var.enable_loadbalancer == "true" ? 1 : 0
}

resource "aws_lb_target_group_attachment" "controller" {
  target_group_arn = aws_lb_target_group.load_balancer[0].arn
  target_id        = element(aws_instance.controller_node.*.id, count.index)
  port             = 443
  count            = var.enable_loadbalancer == "true" ? var.controllers - 1 : 0
}

