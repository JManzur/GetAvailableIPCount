# AWS Region: North of Virginia
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Email list: Add as many emails as you want
variable "target" {
  type = map(string)
  default = {
    target01 = "jmanzurst@gmail.com"
  }
}

/* Tags Variables */
#Use: tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-place-holder" }, )
variable "project-tags" {
  type = map(string)
  default = {
    service     = "AvailableIPCount",
    environment = "POC"
    DeployedBy  = "example@mail.com"
  }
}

variable "resource-name-tag" {
  type    = string
  default = "AvailableIPCount"
}

# Loading TOKEN from .env file ---> Before applying this manifest, run: "source .env"
variable "TOKEN" {
  type        = string
  description = "Telegram BOT Token"
}

# Loading USER_ID from .env file ---> Before applying this manifest, run: "source .env"
variable "USER_ID" {
  type        = string
  description = "Telegram BOT User ID"
}

# Available IP Count threshold (used in lambda to trigger notification)
variable "threshold" {
  type        = number
  description = "Available IP Count threshold"
  default     = 20
}