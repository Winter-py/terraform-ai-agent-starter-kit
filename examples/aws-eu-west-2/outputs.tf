output "logs_bucket_arn" {
  description = "ARN of the example logs bucket."
  value       = aws_s3_bucket.logs.arn
}
