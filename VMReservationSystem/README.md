<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name                                              | Version |
| ------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | latest  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                  | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_api_gateway_deployment.vm_reservation_api_deployment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment)                        | resource    |
| [aws_api_gateway_integration.vm_reservation_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration)                         | resource    |
| [aws_api_gateway_method.vm_reservation_api_method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method)                                    | resource    |
| [aws_api_gateway_resource.vm_reservation_api_resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource)                              | resource    |
| [aws_api_gateway_rest_api.vm_reservation_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api)                                       | resource    |
| [aws_api_gateway_stage.vm_reservation_api_stage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage)                                       | resource    |
| [aws_cloudwatch_log_group.vm_reservation_api_lambda_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                      | resource    |
| [aws_iam_policy.vm_reservation_api_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                             | resource    |
| [aws_iam_role.vm_reservation_api_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                   | resource    |
| [aws_iam_role_policy_attachment.vm_reservation_lambda_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_lambda_function.vm_reservation_api_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                                 | resource    |
| [aws_lambda_permission.vm_reservation_api_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)                           | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                                         | data source |

## Inputs

| Name                                                                             | Description | Type     | Default              | Required |
| -------------------------------------------------------------------------------- | ----------- | -------- | -------------------- | :------: |
| <a name="input_api_name"></a> [api\_name](#input\_api\_name)                     | n/a         | `any`    | n/a                  |   yes    |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name)      | n/a         | `any`    | n/a                  |   yes    |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | n/a         | `any`    | n/a                  |   yes    |
| <a name="input_owner"></a> [owner](#input\_owner)                                | n/a         | `string` | `"Nilesh Choudhary"` |    no    |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name)            | n/a         | `any`    | n/a                  |   yes    |
| <a name="input_region"></a> [region](#input\_region)                             | n/a         | `any`    | n/a                  |   yes    |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name)                  | n/a         | `any`    | n/a                  |   yes    |

## Outputs

| Name                                                                                | Description                                                |
| ----------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| <a name="output_account_id"></a> [account\_id](#output\_account\_id)                | --------------------- Output Sources --------------------- |
| <a name="output_api_arn"></a> [api\_arn](#output\_api\_arn)                         | n/a                                                        |
| <a name="output_caller_arn"></a> [caller\_arn](#output\_caller\_arn)                | n/a                                                        |
| <a name="output_lambda_function"></a> [lambda\_function](#output\_lambda\_function) | n/a                                                        |
| <a name="output_log_group"></a> [log\_group](#output\_log\_group)                   | n/a                                                        |
<!-- END_TF_DOCS -->