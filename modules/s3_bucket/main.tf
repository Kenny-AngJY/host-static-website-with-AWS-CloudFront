resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.main.json
}

data "aws_iam_policy_document" "main" {
  version = "2012-10-17"
  #   Id        = "PolicyForCloudFrontPrivateContent"
  #   version = "2008-10-17"
  statement {
    sid     = "AllowCloudFrontServicePrincipal"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.main.arn}/*"
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [var.distribution_arn]
    }
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = var.bucket_name
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "jpg_image" {
  bucket       = aws_s3_bucket.main.id
  key          = "taylor_swift.jpg"
  source       = "modules/s3_bucket/objects/taylor_swift.jpg"
  content_type = "image/jpeg"
}

resource "aws_s3_object" "maintenance" {
  bucket       = aws_s3_bucket.main.id
  key          = "maintenance.html"
  source       = "modules/s3_bucket/objects/maintenance.html"
  content_type = "text/html"
}