resource "random_password" "spa_demo_db" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "spa_demo" {
  name       = "${local.name}-spa-demo"
  subnet_ids = module.vpc.private_subnets
  tags       = local.common_tags
}

resource "aws_security_group" "spa_demo_db" {
  name        = "${local.name}-spa-demo-db"
  description = "Allow PostgreSQL access from inside the VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_db_instance" "spa_demo" {
  identifier              = "${local.name}-spa-demo"
  engine                  = "postgres"
  engine_version          = "16.4"
  instance_class          = var.spa_demo_db_instance_class
  allocated_storage       = var.spa_demo_db_allocated_storage
  max_allocated_storage   = var.spa_demo_db_allocated_storage * 2
  db_name                 = var.spa_demo_db_name
  username                = var.spa_demo_db_username
  password                = random_password.spa_demo_db.result
  port                    = 5432
  db_subnet_group_name    = aws_db_subnet_group.spa_demo.name
  vpc_security_group_ids  = [aws_security_group.spa_demo_db.id]
  publicly_accessible     = false
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 7
  storage_encrypted       = true

  tags = local.common_tags
}

resource "kubernetes_namespace_v1" "spa_demo" {
  count = var.enable_kubernetes_resources ? 1 : 0

  metadata {
    name = "spa-demo"
  }

  depends_on = [module.eks]
}

resource "kubernetes_secret_v1" "spa_demo_db" {
  count = var.enable_kubernetes_resources ? 1 : 0

  metadata {
    name      = "spa-demo-db"
    namespace = kubernetes_namespace_v1.spa_demo[0].metadata[0].name
  }

  data = {
    DB_HOST     = aws_db_instance.spa_demo.address
    DB_PORT     = tostring(aws_db_instance.spa_demo.port)
    DB_NAME     = aws_db_instance.spa_demo.db_name
    DB_USER     = aws_db_instance.spa_demo.username
    DB_PASSWORD = random_password.spa_demo_db.result
    PORT        = "3000"
    NODE_ENV    = "production"
  }

  type = "Opaque"

  depends_on = [module.eks]
}
