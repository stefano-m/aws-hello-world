/*
Copyright 2020 Stefano Mazzucco

License: GNU GPL v3, see the LICENSE file for more information.
*/


/*

This configuration affects the whole API Gateway Service and normally it should
be managed separately from the Hello World Service. For sake of simplicity, the
configuration is stored together with the service.

On a production-ready deployment, IAM and Account-level settings would be
managed elsewhere and the data needed by the Hello World Service would be
retrievied by either "data sources" or "remote state outputs".

*/


resource "aws_api_gateway_account" "global" {
  cloudwatch_role_arn = aws_iam_role.api_gw_cloudwatch.arn
}

resource "aws_iam_role" "api_gw_cloudwatch" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = local.tags
}

resource "aws_iam_role_policy" "api_gw_cloudwatch" {
  name = "default"
  role = aws_iam_role.api_gw_cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
