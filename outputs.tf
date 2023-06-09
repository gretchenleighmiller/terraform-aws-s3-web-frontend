output "bucket_arn" {
  value       = aws_s3_bucket.bucket.arn
  description = "The ARN of the S3 bucket."
}

output "bucket_id" {
  value       = aws_s3_bucket.bucket.id
  description = "The ID of the S3 bucket."
}

output "cloudfront_arn" {
  value       = aws_cloudfront_distribution.cf.arn
  description = "The ARN of the CloudFront distribution."
}

output "cloudfront_id" {
  value       = aws_cloudfront_distribution.cf.id
  description = "The ID of the CloudFront distribution."
}
