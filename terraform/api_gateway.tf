resource "aws_api_gateway_rest_api" "sell_my_stuff" {
  body = templatefile("${path.module}/files/api/oas.yml", {
    region     = var.region
    lambda_arn = aws_lambda_function.sell_my_stuff.arn
  })

  name = "sellmystuff"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "sell_my_stuff" {
  rest_api_id = aws_api_gateway_rest_api.sell_my_stuff.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.sell_my_stuff.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "sell_my_stuff" {
  deployment_id = aws_api_gateway_deployment.sell_my_stuff.id
  rest_api_id   = aws_api_gateway_rest_api.sell_my_stuff.id
  stage_name    = "prod"
}
