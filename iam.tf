/* IAM Role: Allow Lambda to perform Publish operations on SNS and send Logs to CloudWatch. */

data "aws_iam_policy_document" "policy_source" {
  statement {
    sid    = "CloudWatchAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    sid    = "PublishSNS"
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [
      "${aws_sns_topic.Error_Notification.arn}"
    ]
  }

  statement {
    sid    = "PutIPCountMetric"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DescribeSubnetsByTags"
    effect = "Allow"
    actions = [
      "ec2:DescribeRegions",
      "ec2:DescribeSubnets"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "role_source" {
  statement {
    sid    = "LambdaAssumeRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# IAM Policy
resource "aws_iam_policy" "GetAvailableIPCount_policy" {
  name        = "GetAvailableIPCount_policy"
  path        = "/"
  description = "StartOutbound using Lambda"
  policy      = data.aws_iam_policy_document.policy_source.json
  tags        = merge(var.project-tags, { Name = "${var.resource-name-tag}-policy" }, )
}

# IAM Role (Lambda execution role)
resource "aws_iam_role" "GetAvailableIPCount_policy_role" {
  name               = "GetAvailableIPCount_policy_role"
  assume_role_policy = data.aws_iam_policy_document.role_source.json
  tags               = merge(var.project-tags, { Name = "${var.resource-name-tag}-role" }, )
}

# Attach Role and Policy
resource "aws_iam_role_policy_attachment" "GetAvailableIPCount_attach" {
  role       = aws_iam_role.GetAvailableIPCount_policy_role.name
  policy_arn = aws_iam_policy.GetAvailableIPCount_policy.arn
}