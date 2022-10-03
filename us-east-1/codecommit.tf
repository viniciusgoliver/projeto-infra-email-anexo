### CodeCommit Repositories

resource "aws_codecommit_repository" "service-attatch" {
  repository_name = "service-attatch"
  description     = "Service for sending attachments to the Queue"
}

resource "aws_codecommit_repository" "service-consumer" {
  repository_name = "service-consumer"
  description     = "Service for consuming messages in the queue"
}
