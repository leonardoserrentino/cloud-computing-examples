resource "random_pet" "bucket_suffix" {
  length    = 2
  separator = "-"
}

resource "aws_s3_bucket" "source" {
  bucket        = "${var.environment}-data-source-${random_pet.bucket_suffix.id}"
  force_destroy = true # Allows Terraform to delete the bucket even if it contains files
}

resource "aws_s3_bucket" "destination" {
  bucket        = "${var.environment}-data-dest-${random_pet.bucket_suffix.id}"
  force_destroy = true
}
