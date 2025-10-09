resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = file("${path.module}/files/iam/assume_role.json")
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "sell-my-stuff-lambda-policy"
  policy = file("${path.module}/files/iam/lambda_policy.json")
  role   = aws_iam_role.lambda_role.id
}
