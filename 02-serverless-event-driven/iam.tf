# The trust policy allowing the Lambda service to assume this role
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name               = "${var.environment}-lambda-processor-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# The policy granting specific permissions to the Lambda role
data "aws_iam_policy_document" "lambda_s3_policy" {
  # Allow writing logs to CloudWatch
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  # Allow READING only from the Source bucket
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.source.arn}/*"]
  }

  # Allow WRITING only to the Destination bucket
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.destination.arn}/*"]
  }
}

resource "aws_iam_role_policy" "lambda_s3_attachment" {
  name   = "${var.environment}-lambda-s3-permissions"
  role   = aws_iam_role.lambda_exec_role.id
  policy = data.aws_iam_policy_document.lambda_s3_policy.json
}
