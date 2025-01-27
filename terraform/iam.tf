# AWS SSO Role Okta / Create an AWS IAM Role and connect Okta as a trusted source for that role
# Okta can only provide single-sign-on for users with roles that have been configured to grant access to the Okta SAML Identity Provider.
resource "aws_iam_role" "aws_sso_role" {
  name               = var.sso_role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRoleWithSAML",
      "Condition": {
        "StringEquals": {
          "SAML:aud": "https://signin.aws.amazon.com/saml"
        }
      },
      "Principal": {
        "Federated": "arn:aws:iam::${var.aws_account_id}:saml-provider/aws-sso-identity-provider"
      }
    }
  ]
}	
EOF
}

# SSO role policy / Allows push from Okta dashboard into AWS
resource "aws_iam_role" "sso_role" {
  name = "aws-okta-sso-test-policy-saml"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_account_id}:saml-provider/${var.aws_iam_identity_provider}"
        }
        Action = "sts:AssumeRoleWithSAML"
        Condition = {
          StringEquals = {
            "SAML:aud" = "https://signin.aws.amazon.com/saml"
          }
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "sso_attatchment" {
  role       = aws_iam_role.sso_role.name
  policy_arn = "arn:aws:iam::${var.aws_account_id}:policy/sso_user_service_policy"
}



# SSO Role Policy / Attatch the IAM policy to the IAM Role
resource "aws_iam_policy" "sso_eks_policy" {
  name        = "sso-eks-policy"
  path        = "/"
  description = "AWS SSO role for okta"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "eks:AccessKubernetesApi",
            "eks:DescribeCluster",
            "eks:DescribeFargateProfile",
            "eks:DescribeNodegroup",
            "eks:DescribeUpdate",
            "eks:ListClusters",
            "eks:ListFargateProfiles",
            "eks:ListNodegroups",
            "eks:ListTagsForResource",
            "eks:ListUpdates"
          ],
          "Resource" : "*"
        }
      ]
  })
}
resource "aws_iam_role_policy_attachment" "sso" {
  role       = aws_iam_role.aws_sso_role.name
  policy_arn = aws_iam_policy.sso_eks_policy.arn

  lifecycle {
    create_before_destroy = false
  }
}


# Build a user account / later generate secret / access keys to add into Okta
# Okta needs to fetch available roles from AWS accounts, and it uses AWS users with specific permissions for this.
resource "aws_iam_user" "sso_user" {
  name = var.sso_user
  path = "/services/"

  lifecycle {
    create_before_destroy = false
  }
}

# Create a secret and access credentials #
# After running terraform apply, In yur terminal run: terraform output sso_access_key_id && terraform output sso_secret_access_key
resource "aws_iam_access_key" "sso_key" {
  user = var.sso_user
}

# service user policy / Attatch permissions to list IAM roles to the service user account
resource "aws_iam_policy" "sso_user_service_policy" {
  name        = "sso_user_service_policy"
  path        = "/"
  description = "For Okta check in account"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:ListRoles",
          "iam:ListAccountAliases"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Attatch service policy to the user
resource "aws_iam_user_policy_attachment" "sso_user_service_policy_attatchment" {
  user       = var.sso_user
  policy_arn = aws_iam_policy.sso_user_service_policy.arn
}


















