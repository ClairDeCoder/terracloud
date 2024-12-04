
# Setup S3 Bucket
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/GetStartedWithS3.html
#
resource "aws_s3_bucket" "the_bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Environment = var.environment
    Project     = "Terraform S3 Website"
  }
}

# Website configuration
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/HostingWebsiteOnS3Setup.html
#
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.the_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# S3 Bucket policy
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-policies.html
#
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.the_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = [
          "${aws_s3_bucket.the_bucket.arn}/*",
        ]
      },
    ]
  })
}
