/*
Copyright 2020 Stefano Mazzucco

License: GNU GPL v3, see the LICENSE file for more information.
*/

terraform {
  required_version = "~> 0.13"
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3"
    }
  }

  backend "local" {
    # For larger teams and infrastructure, this would be an S3 backend with
    # state locking and encryption at rest.
  }
}

provider "aws" {
  region = var.region
}

locals {
  common_tags = {
    Environment = title(terraform.workspace)
    Owner       = "PlatformTeam"
    ManagedBy   = "terraform"
  }

  tags = merge(var.extra_tags, local.common_tags)
}

resource "null_resource" "validate_workspace" {
  triggers = {
    allowed_workspace = regex(
      # ensure that the correct workspace name is in use.
      "production|staging|development",
      terraform.workspace
    )
  }
}

output "api_url" {
  description = "The URL to be used to invoke the API"
  value = aws_api_gateway_stage.hello_world.invoke_url
}
