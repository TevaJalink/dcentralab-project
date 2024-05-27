resource "aws_secretsmanager_secret" "RDS_user_credentials" {
  name                    = "RDS-user-cred"
  description             = "RDS user credentials"
  recovery_window_in_days = 0
  tags = {
    Name = "RDS-user-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "RDS_user_credentials" {
  secret_id = aws_secretsmanager_secret.RDS_user_credentials.id
  secret_string = jsonencode({
    username = var.db_user_name
    password = random_password.db_user_password.result
  })
}

resource "aws_iam_role" "RDS_Proxy_Role" {
  name = "rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "rds.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "rds_proxy_policy" {
  name = "rds-proxy-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
          "kms:Decrypt"
        ],
        Effect = "Allow"
        Resource = [
          "${aws_secretsmanager_secret.RDS_user_credentials.arn}",
          "${aws_kms_key.RDS_kms_key.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_proxy_policy_attachment" {
  role       = aws_iam_role.RDS_Proxy_Role.name
  policy_arn = aws_iam_policy.rds_proxy_policy.arn
}

resource "aws_security_group" "RDS_Proxy_SG" {
  name        = "RDS-Proxy-SG"
  description = "Security group for RDS proxy"
  vpc_id      = aws_vpc.Application_VPC.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.Lambda_RDS_Proxy_SG.id]
  }
}

resource "aws_vpc_security_group_egress_rule" "RDS_Proxy_Engress_Rule" {
  security_group_id = aws_security_group.RDS_Proxy_SG.id

  referenced_security_group_id = aws_security_group.RDS_SG.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432

  tags = {
    Name = "RDS-Proxy-To-RDS"
  }
}

resource "aws_db_proxy" "RDS_Proxy" {
  name                   = var.rds_proxy_name
  debug_logging          = false
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = aws_iam_role.RDS_Proxy_Role.arn
  vpc_security_group_ids = [aws_security_group.RDS_Proxy_SG.id]
  vpc_subnet_ids         = aws_subnet.public-subnet[*].id

  auth {
    auth_scheme = "SECRETS"
    description = "Auth config for RDS instances"
    iam_auth    = "REQUIRED"
    secret_arn  = aws_secretsmanager_secret.RDS_user_credentials.arn
  }

  tags = {
    Name = "RDS-Lambda-Proxy"
  }
}

resource "aws_db_proxy_default_target_group" "RDS_Proxy_default_target_group" {
  db_proxy_name = aws_db_proxy.RDS_Proxy.name

  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 100
    max_idle_connections_percent = 50
  }
}

resource "aws_db_proxy_target" "RDS_Proxy_target" {
  db_instance_identifier = aws_db_instance.RDS-Instance.identifier
  db_proxy_name          = aws_db_proxy.RDS_Proxy.name
  target_group_name      = aws_db_proxy_default_target_group.RDS_Proxy_default_target_group.name
}