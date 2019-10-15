
resource "aws_dynamodb_table" "locking" {
  name           = "node-hello-budayabanu-eu-west-1"
  read_capacity  = "20"
  write_capacity = "20"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "state" {
  bucket = "node-hello-budayabanu-eu-west-1"
  region = "eu-west-1"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "terraform-state-bucket"
    Environment = "global"
    project     = "node-hello-app"
  }
}
