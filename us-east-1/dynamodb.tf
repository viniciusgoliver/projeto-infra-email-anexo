# Tabela Attatch Transaction

resource "aws_dynamodb_table" "attatch-transaction" {
  name         = "CollectionAttatchTransaction"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Id"
  
  attribute {
    name = "Id"
    type = "N"
  }

  tags = {
    name = "collection-attatch-transaction"
    env  = "development"
  }
}
