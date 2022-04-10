variable "iam_user" {
  type = string
  description = "Name of IAM user to allow access to repository"
}

variable "account_number" {
  type = number
  description = "Your AWS account number"
}

variable "region" {
  type = string
  description = "AWS Region"
}

variable "repository_name" {
  type = string
  description = "Name of repository to be created"
}

variable "iam_policy_name" {
  type = string
  description = "Name of IAM Policy document"
}