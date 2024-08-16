resource "aws_security_group" "fabric" {
  for_each = var.ec2_network.security_groups

  name   = each.key
  vpc_id = var.ec2_network.vpc_id

  dynamic "ingress" {
    for_each = [for rule in each.value : rule if rule.type == "ingress"]

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  dynamic "egress" {
    for_each = [for rule in each.value : rule if rule.type == "egress"]

    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = each.key
  }
}