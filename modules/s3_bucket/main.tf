data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket" "standard_logging" {
  count  = var.enable_cloudfront_logging ? 1 : 0
  bucket = format("cloudfront-logs-%s", var.random_string)
}

resource "aws_s3_bucket_acl" "standard_logging" {
  count  = var.enable_cloudfront_logging ? 1 : 0
  bucket = aws_s3_bucket.standard_logging[0].id
  access_control_policy {
    grant {
      grantee {
        id   = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0" # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html#AccessLogsBucketAndFileOwnership
        type = "CanonicalUser"                                                    # CanonicalUser | AmazonCustomerByEmail | Group
      }
      permission = "FULL_CONTROL"
    }
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser" # CanonicalUser | AmazonCustomerByEmail | Group
      }
      permission = "FULL_CONTROL"
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "standard_logging" {
  count  = var.enable_cloudfront_logging ? 1 : 0
  bucket = aws_s3_bucket.standard_logging[0].id

  rule {
    object_ownership = "BucketOwnerPreferred" # BucketOwnerPreferred | ObjectWriter | BucketOwnerEnforced
  }
}

resource "aws_s3_bucket" "main" {
  bucket = format("terraform-cloudfront-%s", var.random_string)
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
  bucket = format("terraform-cloudfront-%s", var.random_string)
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

resource "aws_s3_object" "english" {
  bucket       = aws_s3_bucket.main.id
  key          = "en/index.html"
  source       = "modules/s3_bucket/objects/en/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "french" {
  bucket       = aws_s3_bucket.main.id
  key          = "fr/index.html"
  source       = "modules/s3_bucket/objects/fr/index.html"
  content_type = "text/html"
}