variable "aws_region" {
  type        = string
  description = "AWS region this example environment deploys into."
  default     = "eu-west-2"
}

variable "environment" {
  type        = string
  description = "Deployment environment name, used to tag and namespace example resources."
  default     = "example"
}
