terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.1"
    }
  }
}
locals {
  artifacts_bucket = "klaudtech-sell-my-staff-backend"
}

data "aws_s3_object" "lambda_package" {
  bucket = local.artifacts_bucket
  key    = "artifacts/lambda_package.zip"
}

data "aws_s3_object" "dependencies" {
  bucket = local.artifacts_bucket
  key    = "artifacts/dependencies.zip"
}

resource "aws_lambda_function" "sell_my_stuff" {
  function_name     = "sell-my-stuff"
  handler           = "sell_my_stuff.lambda_handler.lambda_handler"
  runtime           = "python3.13"
  role              = aws_iam_role.lambda_role.arn
  s3_bucket         = local.artifacts_bucket
  s3_key            = data.aws_s3_object.lambda_package.key
  s3_object_version = data.aws_s3_object.lambda_package.version_id
  layers            = [aws_lambda_layer_version.dependencies.arn]
  timeout           = 300
}

resource "aws_lambda_layer_version" "dependencies" {
  layer_name          = "dependencies"
  s3_bucket           = local.artifacts_bucket
  s3_key              = data.aws_s3_object.dependencies.key
  s3_object_version   = data.aws_s3_object.dependencies.version_id
  compatible_runtimes = ["python3.13"]
}

resource "aws_lambda_permission" "sell_my_stuff" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sell_my_stuff.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.sell_my_stuff.execution_arn}/*/*"
}
