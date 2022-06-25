## Bucket for TF state storage
resource "aws_s3_bucket" "tfstate" {
  bucket = "mkaito-tfstate"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_acl" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

## DynamoDB for TF locking and state
resource "aws_dynamodb_table" "tfstatelock" {
  name = "mkaito-tfstate-lock"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  lifecycle {
    prevent_destroy = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}
