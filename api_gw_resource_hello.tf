/*
Copyright 2020 Stefano Mazzucco

License: GNU GPL v3, see the LICENSE file for more information.
*/

resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.hello_world.id
  parent_id   = aws_api_gateway_rest_api.hello_world.root_resource_id
  path_part   = "hello"
}

resource "aws_api_gateway_method" "hello_get" {
  rest_api_id   = aws_api_gateway_rest_api.hello_world.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_get" {
  rest_api_id = aws_api_gateway_rest_api.hello_world.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_get.http_method
  type        = "MOCK"

  passthrough_behavior = "WHEN_NO_TEMPLATES"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}" # keep this or you'll get an internal server error from AWS!
  }
}

resource "aws_api_gateway_method_response" "hello_get_200" {
  rest_api_id = aws_api_gateway_rest_api.hello_world.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = 200
  response_parameters = {
    "method.response.header.content-type" = true
  }
}

resource "aws_api_gateway_integration_response" "hello_get_200" {
  depends_on = [aws_api_gateway_integration.hello_get]

  rest_api_id = aws_api_gateway_rest_api.hello_world.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = 200

  response_templates = {
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-mapping-template-reference.html#context-variable-reference
    # $context.requestTime: dd/MMM/yyyy:HH:mm:ss +-hhmm
    "text/plain" = "hello, world! $context.requestTime"
  }

  response_parameters = {
    "method.response.header.content-type" = "'text/plain'"
  }

}
