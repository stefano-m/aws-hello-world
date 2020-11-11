/*
Copyright 2020 Stefano Mazzucco

License: GNU GPL v3, see the LICENSE file for more information.
*/


resource "aws_api_gateway_rest_api" "hello_world" {
  name        = "HelloWorld"
  description = "Hello World Service"

  endpoint_configuration {
    types = [var.api_gw_endpoint_type]
  }

  tags = merge(local.tags, { Name = "HelloWorldApi" })
}

resource "aws_api_gateway_deployment" "hello_world" {
  depends_on = [aws_api_gateway_integration.hello_get]

  rest_api_id = aws_api_gateway_rest_api.hello_world.id

  triggers = {
    redeploy = sha1(
      join(",",
        list(jsonencode(aws_api_gateway_integration.hello_get))
    ))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_method_settings" "hello_world" {
  rest_api_id = aws_api_gateway_rest_api.hello_world.id
  stage_name  = aws_api_gateway_stage.hello_world.stage_name
  method_path = "*/*" # enables metrics for the whole stage, not just a specific method.

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

resource "aws_api_gateway_stage" "hello_world" {
  stage_name    = var.api_gw_stage_name
  rest_api_id   = aws_api_gateway_rest_api.hello_world.id
  deployment_id = aws_api_gateway_deployment.hello_world.id

  # CloudWatch Logs are configured in aws_api_gateway_method_settings.hello_world

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_hello_world.arn

    # Use JSON format so it can be easily queried with CloudWatch Logs Insights (no need for an ELK stack)
    format = jsonencode(
      # See:
      # - https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html#apigateway-cloudwatch-log-formats
      # - https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-mapping-template-reference.html
      {
        requestId      = "$context.requestId"
        ip             = "$context.identity.sourceIp"
        caller         = "$context.identity.caller"
        user           = "$context.identity.user"
        requestTime    = "$context.requestTime"
        httpMethod     = "$context.httpMethod"
        resourcePath   = "$context.resourcePath"
        status         = "$context.status"
        protocol       = "$context.protocol"
        responseLength = "$context.responseLength"
        domainName     = "$context.domainName"
      }
    )

  }

  depends_on = [aws_cloudwatch_log_group.api_gw_hello_world]

  tags = merge(local.tags, { Name = "HelloWorldStage" })
}

resource "aws_cloudwatch_log_group" "api_gw_hello_world" {
  # Follows API GW naming convention. See:
  # https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html#apigateway-cloudwatch-log-formats
  name = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.hello_world.id}/${var.api_gw_stage_name}"

  retention_in_days = terraform.workspace == "development" ? 7 : 180

  tags = merge(local.tags, { Name = "HelloWorldLogs" })
}
