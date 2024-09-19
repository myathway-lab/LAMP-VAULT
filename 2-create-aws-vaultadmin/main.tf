provider "aws" {
  region = var.aws_region
}

resource "aws_iam_user" "vault_admin" {
  name = var.user_name
  path = "/"

  tags = {
    Name = var.user_name
  }
}

resource "aws_iam_access_key" "vault_admin_accesskey" {
  user = aws_iam_user.vault_admin.name
  lifecycle {
    ignore_changes = [
      user
    ]
  }
}

data "aws_iam_policy_document" "inline_po_vault" {
  statement {
    effect = "Allow"
    actions = [
      "iam:AttachUserPolicy",
      "iam:CreateUser",
      "iam:CreateAccessKey",
      "iam:DeleteUser",
      "iam:DeleteAccessKey",
      "iam:DeleteUserPolicy",
      "iam:DetachUserPolicy",
      "iam:GetUser",
      "iam:ListAccessKeys",
      "iam:ListAttachedUserPolicies",
      "iam:ListGroupsForUser",
      "iam:ListUserPolicies",
      "iam:PutUserPolicy",
      "iam:AddUserToGroup",
      "iam:RemoveUserFromGroup"
    ]
    resources = [
      "arn:aws:iam::010526263030:user/vault-*"
    ]
  }
}

resource "aws_iam_user_policy" "inline_po_attach" {
  name   = var.inline_po_name
  user   = aws_iam_user.vault_admin.name
  policy = data.aws_iam_policy_document.inline_po_vault.json
}
