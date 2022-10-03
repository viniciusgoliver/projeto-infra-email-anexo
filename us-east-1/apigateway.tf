// API GATEWAY
resource "aws_api_gateway_rest_api" "attatch_service_api" {
  name = "attatch-service-api"
}

// API GATEWAY RESOURCES
resource "aws_api_gateway_resource" "attatch_service" {
  path_part   = "attatch-service"
  parent_id   = aws_api_gateway_rest_api.attatch_service_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.attatch_service_api.id
}

resource "aws_api_gateway_method" "attatch_service_api_rest_api_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.attatch_service_api.id
  resource_id   = aws_api_gateway_resource.attatch_service.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "attatch_service_rest_api_post_method_integration" {
  rest_api_id             = aws_api_gateway_rest_api.attatch_service_api.id
  resource_id             = aws_api_gateway_resource.attatch_service.id
  http_method             = aws_api_gateway_method.attatch_service_api_rest_api_post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.fn_service_attatch.invoke_arn
}

resource "aws_api_gateway_method_response" "attatch_service_rest_api_post_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.attatch_service_api.id
  resource_id = aws_api_gateway_resource.attatch_service.id
  http_method = aws_api_gateway_method.attatch_service_api_rest_api_post_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = [aws_api_gateway_method.attatch_service_api_rest_api_post_method]
}

resource "aws_lambda_permission" "api_gateway_fn_service_attatch" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fn_service_attatch.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.attatch_service_api.execution_arn}/*/*/${aws_api_gateway_resource.attatch_service.path_part}"
}

// DEPLOY
resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.attatch_service_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.attatch_service_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.attatch_service_rest_api_post_method_integration,
    aws_api_gateway_method_response.attatch_service_rest_api_post_method_response_200                 
  ]
}

// STAGE
resource "aws_api_gateway_stage" "rest_api_stage" {
  deployment_id = aws_api_gateway_deployment.rest_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.attatch_service_api.id
  stage_name    = "dev"
}
