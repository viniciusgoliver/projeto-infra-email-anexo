resource "aws_iam_role" "services_build_iam_role" {
  name = "services-build-iam-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "services_build_iam_role_policy" {
  role = aws_iam_role.services_build_iam_role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

# Build Service Consumer

resource "aws_codebuild_project" "service_consumer_build" {
  name          = "service-consumer-build"
  description   = "Build Service Consumer"
  build_timeout = "5"
  service_role  = aws_iam_role.services_build_iam_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/service-consumer"
    buildspec       = file("${path.module}/buildspec-files/buildspec-service-consumer.yml")
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "refs/heads/master"

  tags = {
    env = "development"
  }
}


# Build Service Attatch

resource "aws_codebuild_project" "service_attatch_build" {
  name          = "service-attatch-build"
  description   = "Build Service Attatch"
  build_timeout = "5"
  service_role  = aws_iam_role.services_build_iam_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/service-attatch"
    buildspec       = file("${path.module}/buildspec-files/buildspec-service-attatch.yml")
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "refs/heads/master"

  tags = {
    env = "development"
  }
}
