output {
    description = "URI for the repository"
    value = aws_ecr_repository.my-repo.repository_url
}


output "iam_policy_name" {
    description = "iam policy to attach to user to authenticate with ECR and view repositories"
    value = aws_iam_policy.policy.name
}