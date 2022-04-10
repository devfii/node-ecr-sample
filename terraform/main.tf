terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.8.0"
        }

    }

    required_version = "~> 1.1.7"

}

provider "aws" {
    profile = "admin"
    region = "eu-west-1"

}

resource "aws_iam_policy" "policy" {
  name        = var.iam_policy_name
  path        = "/"
  description = "Policy to attach to an IAM user/group. The policy grants permissions to users to Generate authorization token and view respositories"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "ECRAuthorization"
        Action = [
          "ecr:GetAuthorizationToken", "ecr:DescribeRepositories", "ecr:CreateRepository"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_ecr_repository" "my-repo" {
    name = var.repository_name
    image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

}

resource "aws_ecr_repository_policy" "my-repo-policy" {
  repository = aws_ecr_repository.my-repo.name

  policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "ECR Repository Policy",
        "Effect": "Allow",
        "Principal": {
            "AWS": ["arn:aws:iam::${var.account_id}:user/${var.iam_user}"]
        },
        "Action": [
            "ecr:BatchCheckLayerAvailability",
            "ecr:BatchDeleteImage",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetRepositoryPolicy",
            "ecr:ListImages",
            "ecr:DescribeImages",
            "ecr:BatchGetImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:PutImage"
        ]
        }
    ]
    }
    EOF
}
