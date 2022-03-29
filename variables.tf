# AWS Region: North of Virginia
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Email list: Add as many emails as you want
variable "target" {
  type = map(string)
  default = {
    target01 = "example@gmail.com"
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