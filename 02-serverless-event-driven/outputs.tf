output "source_bucket_name" {
  description = "Upload CSV files to this bucket"
  value       = aws_s3_bucket.source.bucket
}

output "destination_bucket_name" {
  description = "Processed JSON files will appear here"
  value       = aws_s3_bucket.destination.bucket
}
