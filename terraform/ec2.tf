# Standalone EC2 instance reachable over SSH with two randomly generated
# password logins, with Docker pre-installed. The instance lands in a public
# subnet and is reported via its AWS-assigned public DNS name (no named DNS
# zone is created).

# ---------------------------------------------------------------------------
# Randomly generated credentials
# ---------------------------------------------------------------------------
# 16 random characters appended to the "user"/"admin" keyword to form each
# Linux username (lowercase + digits keeps them valid for useradd).
resource "random_string" "ec2_user_suffix" {
  length  = 16
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "random_string" "ec2_admin_suffix" {
  length  = 16
  lower   = true
  upper   = false
  numeric = true
  special = false
}

# 16-character complex passwords (guaranteed upper/lower/digit/special mix).
resource "random_password" "ec2_user" {
  length           = 16
  special          = true
  override_special = "!#%*+=-_?"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "random_password" "ec2_admin" {
  length           = 16
  special          = true
  override_special = "!#%*+=-_?"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

locals {
  ec2_user_username  = "user${random_string.ec2_user_suffix.result}"
  ec2_admin_username = "admin${random_string.ec2_admin_suffix.result}"

  # Structured view of the accounts for outputs.
  ec2_accounts = {
    admin = {
      username = local.ec2_admin_username
      password = random_password.ec2_admin.result
      sudo     = true
    }
    user = {
      username = local.ec2_user_username
      password = random_password.ec2_user.result
      sudo     = false
    }
  }

  ec2_user_data = templatefile("${path.module}/templates/ec2-cloud-init.yaml.tftpl", {
    admin_username = local.ec2_admin_username
    admin_password = random_password.ec2_admin.result
    user_username  = local.ec2_user_username
    user_password  = random_password.ec2_user.result
  })
}

# ---------------------------------------------------------------------------
# Latest Amazon Linux 2023 AMI (x86_64) — ships dnf-installable docker.
# ---------------------------------------------------------------------------
data "aws_ami" "al2023" {
  count       = var.ec2_enabled ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ---------------------------------------------------------------------------
# Security group: inbound SSH from the configured CIDRs.
# ---------------------------------------------------------------------------
# NOTE: ec2_ssh_ingress_cidrs defaults to 0.0.0.0/0 (open to all). Restrict it to
# specific source CIDR(s) to reduce exposure.
resource "aws_security_group" "ec2_ssh" {
  count = var.ec2_enabled ? 1 : 0

  name        = "${local.name}-ec2-ssh"
  description = "Allow inbound SSH to the demo EC2 instance"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = length(var.ec2_ssh_ingress_cidrs) > 0 ? [1] : []
    content {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ec2_ssh_ingress_cidrs
    }
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name}-ec2-ssh"
  })
}

# ---------------------------------------------------------------------------
# Instance role: SSM Session Manager access (key-less admin path / fallback).
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "ec2_ssm_assume_role" {
  count = var.ec2_enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_ssh" {
  count              = var.ec2_enabled ? 1 : 0
  name               = "${local.name}-ec2-ssh"
  assume_role_policy = data.aws_iam_policy_document.ec2_ssm_assume_role[0].json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ec2_ssh_ssm" {
  count      = var.ec2_enabled ? 1 : 0
  role       = aws_iam_role.ec2_ssh[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssh" {
  count = var.ec2_enabled ? 1 : 0
  name  = "${local.name}-ec2-ssh"
  role  = aws_iam_role.ec2_ssh[0].name
  tags  = local.common_tags
}

# ---------------------------------------------------------------------------
# The EC2 instance
# ---------------------------------------------------------------------------
resource "aws_instance" "ssh_demo" {
  count = var.ec2_enabled ? 1 : 0

  ami                         = data.aws_ami.al2023[0].id
  instance_type               = var.ec2_instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ec2_ssh[0].id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssh[0].name
  associate_public_ip_address = true
  user_data                   = local.ec2_user_data

  # Re-provision if the rendered cloud-init (users/passwords) changes.
  user_data_replace_on_change = true

  # Enforce IMDSv2.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.ec2_root_volume_size
    encrypted   = true

    tags = merge(local.common_tags, {
      Name = "${local.name}-ssh-demo-root"
    })
  }

  tags = merge(local.common_tags, {
    Name = "${local.name}-ssh-demo"
  })
}
