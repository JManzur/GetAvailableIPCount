/* SNS Topic - Send email notification from Lambda (on failure) */

resource "aws_sns_topic" "Error_Notification" {
  name = "Error_Notification"
  tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-sns-topic" }, )
}

resource "aws_sns_topic_subscription" "email-targets" {
  for_each  = var.target
  topic_arn = aws_sns_topic.Error_Notification.arn
  protocol  = "email"
  endpoint  = each.value
}