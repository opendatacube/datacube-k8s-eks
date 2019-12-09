terraform {
  required_version = ">= 0.11.0"

  backend "s3" {
    # Force encryption
    encrypt = true
  }
}

provider "aws" {
  region = "${var.region}"
}

provider "archive" {
  
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "bitbucket_app_username" {
  name = "DEADDatakubeBitBucketAppUsername"
}

data "aws_ssm_parameter" "bitbucket_app_password" {
  name = "DEADDatakubeBitBucketAppPassword"
}

data "archive_file" "keel_lambda_package" {
  type = "zip"
  source_file = "${path.module}/lambda/keel.js"
  output_path = "${path.module}/lambda/keel.zip"
}

resource "aws_api_gateway_rest_api" "gateway" {
  name = "DEADatakubeContainerOrchestration"
  description = "API for invoking DEA Datakube container orchestration lambdas"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Principal": "*",
#             "Action": "execute-api:Invoke",
#             "Resource": "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:*/*/*",
#             "Condition": {
#                 "IpAddress": {
#                     "aws:SourceIp": [
#                         "54.173.229.200",
#                         "54.175.230.252"
#                     ]
#                 }
#             }
#         }
#     ]
# }
# EOF
}


resource "aws_api_gateway_deployment" "gateway" {
  depends_on  = ["aws_api_gateway_integration.keel_integration"]
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  stage_name  = "alpha"
}

resource "aws_api_gateway_resource" "gateway_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  parent_id = "${aws_api_gateway_rest_api.gateway.root_resource_id}"
  path_part = "keel"
}

resource "aws_api_gateway_method" "keel" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id = "${aws_api_gateway_resource.gateway_resource.id}"
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_settings" "keel" {
  depends_on = ["aws_api_gateway_deployment.gateway"]
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  stage_name  = "alpha"
  method_path = "${aws_api_gateway_resource.gateway_resource.path_part}/${aws_api_gateway_method.keel.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
    data_trace_enabled = true
  }
}

resource "aws_api_gateway_method_response" "keel" {
  http_method = "${aws_api_gateway_integration.keel_integration.http_method}"
  resource_id = "${aws_api_gateway_resource.gateway_resource.id}"
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "keel" {
  http_method = "${aws_api_gateway_method_response.keel.http_method}"
  resource_id = "${aws_api_gateway_resource.gateway_resource.id}"
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  status_code = "${aws_api_gateway_method_response.keel.status_code}"
}

resource "aws_api_gateway_integration" "keel_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id             = "${aws_api_gateway_resource.gateway_resource.id}"
  http_method             = "${aws_api_gateway_method.keel.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.keel_lambda.arn}/invocations"
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.keel_lambda.arn}"
  principal     = "apigateway.amazonaws.com"
  depends_on = ["aws_api_gateway_rest_api.gateway","aws_api_gateway_resource.gateway_resource"]
  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "${aws_api_gateway_deployment.gateway.execution_arn}/*/*"
}

resource "aws_lambda_function" "keel_lambda" {
  filename         = "${data.archive_file.keel_lambda_package.output_path}"
  function_name    = "DEADatakubeContainerOrchestration"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "keel.handler"
  # workaround so terraform doesn't try and update
  # unchanged file https://github.com/hashicorp/terraform/issues/7613
  source_code_hash = "${base64sha256(file("${substr(data.archive_file.keel_lambda_package.output_path, length(path.cwd) + 1, -1)}"))}"
  runtime          = "nodejs8.10"
  timeout          = 45

  environment {
    variables = {
      BITBUCKET_PIPELINE_USERNAME = "${data.aws_ssm_parameter.bitbucket_app_username.value}"
      BITBUCKET_PIPELINE_APP_PASSWORD = "${data.aws_ssm_parameter.bitbucket_app_password.value}"
      PIPELINE_HOST = "api.bitbucket.org"
      PIPELINE_PATH = "/2.0/repositories/geoscienceaustralia/datakube/pipelines/"
    }
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "DEADatakubeKeelLambdaRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logs" {
  name = "DEADatakubeKeelLambdaLogPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_logs.arn}"
}

resource "aws_iam_role" "iam_for_apigateway" {
  name = "DEADatakubeKeelAPIGatewayRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "apigateway_logs" {
  role = "${aws_iam_role.iam_for_apigateway.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}
