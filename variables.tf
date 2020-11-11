/*
Copyright 2020 Stefano Mazzucco

License: GNU GPL v3, see the LICENSE file for more information.
*/

variable "api_gw_endpoint_type" {
  type        = string
  description = "The type of API Gateway Endpoint"
  default     = "REGIONAL"

  validation {
    condition     = contains(["EDGE", "REGIONAL", "PRIVATE"], var.api_gw_endpoint_type)
    error_message = "Should be one of EDGE, REGIONAL or PRIVATE."
  }
}

variable "api_gw_stage_name" {
  type        = string
  description = <<END

  The name of the API Gateway Stage. This is used to avoid cycles within the
  configuration (e.g. between CloudWatch Log Groups and Stage).

END

  default = "v1"
}

variable "region" {
  type        = string
  description = "The AWS region where to deploy."
  default     = "eu-west-2"
}

variable "extra_tags" {
  type        = map
  description = "Extra tags to add to the resources"
  default     = {}
}
