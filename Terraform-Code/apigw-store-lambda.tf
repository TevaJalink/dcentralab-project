resource "aws_api_gateway_rest_api" "Lambda-Store" {
  name = "Store-input-to-rds"
}

resource "aws_api_gateway_resource" "Lambda-Store-Resource" {
  rest_api_id = aws_api_gateway_rest_api.Lambda-Store.id
  parent_id   = aws_api_gateway_rest_api.Lambda-Store.root_resource_id
  path_part   = var.input_api_path
}

resource "aws_api_gateway_method" "Lambda-Store-Method" {
  rest_api_id   = aws_api_gateway_rest_api.Lambda-Store.id
  resource_id   = aws_api_gateway_resource.Lambda-Store-Resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "Lambda-Store-Integration" {
  rest_api_id             = aws_api_gateway_rest_api.Lambda-Store.id
  resource_id             = aws_api_gateway_resource.Lambda-Store-Resource.id
  http_method             = aws_api_gateway_method.Lambda-Store-Method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rds_proxy_store_function.invoke_arn
}

resource "aws_lambda_permission" "APIGW-Permissions-For-Store-Lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_proxy_store_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.Lambda-Store.execution_arn}/*/${aws_api_gateway_method.Lambda-Store-Method.http_method}${aws_api_gateway_resource.Lambda-Store-Resource.path}"
}

resource "aws_api_gateway_deployment" "Lambda-Store-Deployment" {
  rest_api_id = aws_api_gateway_rest_api.Lambda-Store.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.Lambda-Store,
      aws_api_gateway_resource.Lambda-Store-Resource,
      aws_api_gateway_method.Lambda-Store-Method,
      aws_api_gateway_integration.Lambda-Store-Integration
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_method.Lambda-Store-Method, aws_api_gateway_integration.Lambda-Store-Integration]
}

resource "aws_api_gateway_stage" "Lambda-Store-Stage" {
  deployment_id = aws_api_gateway_deployment.Lambda-Store-Deployment.id
  rest_api_id   = aws_api_gateway_rest_api.Lambda-Store.id
  stage_name    = var.Input_Lambda_Stage_Name
}