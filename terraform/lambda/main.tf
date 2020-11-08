resource "aws_iam_policy" "es4ec2_lambda_policy" {
  name        = var.lambda_execution_role_name
  path        = "/"
  description = var.lambda_execution_role_description

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
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeNetworkInterfaces",
        "ec2:UnassignPrivateIpAddresses",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances",
        "ec2:AssignPrivateIpAddresses",
        "ec2:AttachNetworkInterface"
      ],
      "Resource": "*"
    },
    {
         "Action":[
            "es:*"
         ],
         "Effect":"Allow",
         "Resource":"*"
      }
  ]
}
EOF
}

resource "aws_iam_role" "iam_for_lambda" {
  name = var.lambda_iam_role_name

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

resource "aws_iam_role_policy_attachment" "attach_es4ec2_policy_to_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.es4ec2_lambda_policy.arn
}

resource "aws_lambda_function" "ec2_state_change_to_es" {
  filename      = "../lambda/lambda_function.zip"
  function_name = var.lambda_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("../lambda/lambda_function.zip")

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  runtime = "python3.8"

  timeout = "60"



  environment {
    variables = {
      es_endpoint = var.es_endpoint
    }
  }
}