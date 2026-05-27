# Package the Python script
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/src/data_processor.py"
  output_path = "${path.module}/lambda_function.zip"
}

# Create the Lambda function
resource "aws_lambda_function" "data_processor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.environment}-csv-to-json-processor"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "data_processor.lambda_handler"
  runtime          = "python3.10"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 10

  environment {
    variables = {
      DESTINATION_BUCKET = aws_s3_bucket.destination.bucket
    }
  }
}

# Grant S3 permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_processor.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source.arn
}

# Configure the S3 bucket to trigger the Lambda on object creation
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.source.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.data_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv" # Only trigger for CSV files
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
