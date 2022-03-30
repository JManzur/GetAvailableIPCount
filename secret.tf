/* Before applying this manifest, run: "source .env" */

# Secret definition:
resource "aws_secretsmanager_secret" "telegram_bot_credentials" {
  name        = "telegram_bot_credentials"
  description = "Used by GetAvailableIPCount Lambda"
}

# Retrieve secret values from local .env file
resource "aws_secretsmanager_secret_version" "telegram_bot_credentials_v1" {
  secret_id     = aws_secretsmanager_secret.telegram_bot_credentials.id
  secret_string = <<EOF
  {
    "bot_token": "${var.TOKEN}",
    "user_id": "${var.USER_ID}"
  }
EOF
}