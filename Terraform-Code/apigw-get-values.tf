resource "aws_api_gateway_rest_api" "Lambda-Get-Values" {
  name = "Get-values-from-rds"
}

resource "aws_api_gateway_resource" "Lambda-Get-Values-Resource" {
  rest_api_id = aws_api_gateway_rest_api.Lambda-Get-Values.id
  parent_id   = aws_api_gateway_rest_api.Lambda-Get-Values.root_resource_id
  path_part   = var.get_api_path
}

resource "aws_api_gateway_method" "Lambda-Get-Values-Method" {
  rest_api_id   = aws_api_gateway_rest_api.Lambda-Get-Values.id
  resource_id   = aws_api_gateway_resource.Lambda-Get-Values-Resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "Lambda-Get-Values-Integration" {
  rest_api_id             = aws_api_gateway_rest_api.Lambda-Get-Values.id
  resource_id             = aws_api_gateway_resource.Lambda-Get-Values-Resource.id
  http_method             = aws_api_gateway_method.Lambda-Get-Values-Method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rds_proxy_get_function.invoke_arn
}

resource "aws_lambda_permission" "APIGW-Permissions-For-Get-Lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_proxy_get_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.Lambda-Get-Values.execution_arn}/*/${aws_api_gateway_method.Lambda-Get-Values-Method.http_method}${aws_api_gateway_resource.Lambda-Get-Values-Resource.path}"
}

resource "aws_api_gateway_deployment" "Lambda-Get-Values-Deployment" {
  rest_api_id = aws_api_gateway_rest_api.Lambda-Get-Values.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.Lambda-Get-Values,
      aws_api_gateway_resource.Lambda-Get-Values-Resource,
      aws_api_gateway_method.Lambda-Get-Values-Method,
      aws_api_gateway_integration.Lambda-Get-Values-Integration
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_method.Lambda-Get-Values-Method, aws_api_gateway_integration.Lambda-Get-Values-Integration]
}

resource "aws_api_gateway_stage" "Lambda-Get-Values-Stage" {
  deployment_id = aws_api_gateway_deployment.Lambda-Get-Values-Deployment.id
  rest_api_id   = aws_api_gateway_rest_api.Lambda-Get-Values.id
  stage_name    = var.Get_stage_name
}