resource "aws_dynamodb_table" "table" {
  name         = "omi"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  attribute {
    name = "GSI1PK"
    type = "S"
  }

  attribute {
    name = "GSI1SK"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1PK-GSI1SK-index"
    hash_key        = "GSI1PK"
    range_key       = "GSI1SK"
    projection_type = "ALL"
  }

  hash_key  = "PK"
  range_key = "SK"

  tags = {
    Name        = "hec"
    Environment = "dev"
  }
}
