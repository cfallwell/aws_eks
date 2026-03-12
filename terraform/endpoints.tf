resource "aws_security_group" "aws_api_endpoints" {
  count = var.enable_private_aws_api_endpoints ? 1 : 0

  name        = "${local.name}-aws-api-endpoints"
  description = "Allow VPC workloads to reach private AWS API endpoints over HTTPS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS from inside the VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name}-aws-api-endpoints"
  })
}

resource "aws_vpc_endpoint" "aws_api" {
  for_each = var.enable_private_aws_api_endpoints ? toset(["ec2", "sts"]) : toset([])

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.vpc.private_subnets

  security_group_ids = [
    aws_security_group.aws_api_endpoints[0].id,
  ]

  tags = merge(local.common_tags, {
    Name = "${local.name}-${each.key}-endpoint"
  })
}
