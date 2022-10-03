resource "aws_s3_bucket" "cliente_anexo" {
  bucket = "cliente-anexo"
  acl    = "public-read"

  tags = {
    Name = "Costumer Bucket"
  }
}
