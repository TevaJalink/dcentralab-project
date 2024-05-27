resource "aws_iam_role" "Lambda_Exec_Role" {
  name = "Lambda-RDS-Proxy-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_policy" "Lambda_Exec_Policy" {
  name = "Lambda-RDS-Proxy-Policy"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "rds-db:connect"
            ],
            "Resource": "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${element(split(":", aws_db_proxy.RDS_Proxy.arn), 6)}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ec2:DescribeInstances",
                "ec2:CreateNetworkInterface",
                "ec2:AttachNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "autoscaling:CompleteLifecycleAction",
                "ec2:DeleteNetworkInterface"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "Lambda_Policy" {
  role       = aws_iam_role.Lambda_Exec_Role.name
  policy_arn = aws_iam_policy.Lambda_Exec_Policy.arn
}

resource "aws_security_group" "Lambda_RDS_Proxy_SG" {
  name        = "Lambda-RDS-Proxy-SG"
  description = "Security group for lambda connection to RDS"
  vpc_id      = aws_vpc.Application_VPC.id
}

resource "aws_vpc_security_group_egress_rule" "Lambda_Engress_Rule_Proxy" {
  security_group_id = aws_security_group.Lambda_RDS_Proxy_SG.id

  referenced_security_group_id = aws_security_group.RDS_Proxy_SG.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432

  tags = {
    Name = "Lambda-To-RDS-Proxy"
  }
}

resource "aws_vpc_security_group_egress_rule" "Lambda_Engress_Rule_Instance" {
  security_group_id = aws_security_group.Lambda_RDS_Proxy_SG.id

  referenced_security_group_id = aws_security_group.RDS_SG.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432

  tags = {
    Name = "Lambda-To-RDS-Instance"
  }
}

resource "aws_cloudwatch_log_group" "store_lambda_log" {
  name              = "/aws/lambda/${aws_lambda_function.rds_proxy_store_function.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "get_lambda_log" {
  name              = "/aws/lambda/${aws_lambda_function.rds_proxy_get_function.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "rds_proxy_store_function" {
  function_name = "Store-Values-in-RDS"
  runtime       = "python3.10"
  handler       = "main.lambda_handler"
  filename      = "Input-Values-Lambda.zip"
  role          = aws_iam_role.Lambda_Exec_Role.arn
  timeout       = 30

  vpc_config {
    subnet_ids         = aws_subnet.public-subnet[*].id
    security_group_ids = [aws_security_group.Lambda_RDS_Proxy_SG.id]
  }
  environment {
    variables = {
      region : var.aws_region,
      rds_endpoint : aws_db_proxy.RDS_Proxy.endpoint,
      port : 5432,
      username : var.db_user_name
      database : var.db_name
    }
  }
}

resource "aws_lambda_function" "rds_proxy_get_function" {
  function_name = "Get-Values-in-RDS"
  runtime       = "python3.10"
  handler       = "main.lambda_handler"
  filename      = "Get-Value-Lambda.zip"
  role          = aws_iam_role.Lambda_Exec_Role.arn
  timeout       = 30

  vpc_config {
    subnet_ids         = aws_subnet.public-subnet[*].id
    security_group_ids = [aws_security_group.Lambda_RDS_Proxy_SG.id]
  }
  environment {
    variables = {
      region : var.aws_region,
      rds_endpoint : aws_db_proxy.RDS_Proxy.endpoint,
      port : 5432,
      username : var.db_user_name
      database : var.db_name
    }
  }
}