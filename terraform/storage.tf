resource "aws_s3_bucket" "spa_demo" {
  bucket = local.spa_demo_s3_bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "spa_demo" {
  bucket = aws_s3_bucket.spa_demo.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "spa_demo" {
  bucket = aws_s3_bucket.spa_demo.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "spa_demo" {
  bucket                  = aws_s3_bucket.spa_demo.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
