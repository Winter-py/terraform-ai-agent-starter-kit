resource "aws_s3_bucket" "logs" {
  bucket = "${var.environment}-app-logs-example"

  tags = {
    environment = var.environment
    managed_by  = "terraform-copilot-agent-starter-kit"
  }
}
