# Event Rule to Trigger GetIPCountLambda
resource "aws_cloudwatch_event_rule" "get-ip-count" {
  name                = "get-ip-count"
  description         = "Get available IP count every 5 minutes"
  schedule_expression = "cron(0/5 * ? * * *)"
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "lambda_getip_target" {
  rule      = aws_cloudwatch_event_rule.get-ip-count.name
  target_id = "lambda"
  arn       = aws_lambda_function.GetAvailableIPCount.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_getip_function" {
  statement_id  = "TriggerGetIPCountLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.GetAvailableIPCount.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.get-ip-count.arn
}