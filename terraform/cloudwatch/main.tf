resource "aws_cloudwatch_event_rule" "ec2_state_changed" {
  name        = var.cloud_watch_rule_name
  description = var.cloud_watch_rule_description

  event_pattern = <<EOF
    {
        "source": [
        "aws.ec2"
    ],
        "detail-type": [
            "EC2 Instance State-change Notification"
        ]
    }
    EOF
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.ec2_state_changed.name
  target_id = "lambda"
  arn       = var.lambda_arn
}

resource "aws_lambda_permission" "ec2_state_change_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_state_changed.arn
}

