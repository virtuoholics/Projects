resource "aws_s3_bucket" "devsecops" {
  bucket = "devsecops-project-analysis-bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "devsecops_sse" {
  bucket = aws_s3_bucket.devsecops.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "devsecops_ver" {
  bucket = aws_s3_bucket.devsecops.id

  versioning_configuration {
    status = "Enabled"
  }
}
