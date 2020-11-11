## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.13 |
| aws | ~> 3 |
| null | ~> 3 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3 |
| null | ~> 3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| api\_gw\_endpoint\_type | The type of API Gateway Endpoint | `string` | `"REGIONAL"` | no |
| api\_gw\_stage\_name | The name of the API Gateway Stage. This is used to avoid cycles within the<br>  configuration (e.g. between CloudWatch Log Groups and Stage). | `string` | `"v1"` | no |
| extra\_tags | Extra tags to add to the resources | `map` | `{}` | no |
| region | The AWS region where to deploy. | `string` | `"eu-west-2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| api\_url | The URL to be used to invoke the API |

