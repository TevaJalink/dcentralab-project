output "Lambda_Store_Endpoint_URL" {
  value = "${aws_api_gateway_stage.Lambda-Store-Stage.invoke_url}/${var.input_api_path}?id=<add a 9 numbers number>&GivenName=<add a private name>&Surname=<add a family name>"
}

output "Lambda_Get_Value_Endpoint_URL" {
  value = "${aws_api_gateway_stage.Lambda-Get-Values-Stage.invoke_url}/${var.get_api_path}"
}