variable "aws_account_id" {
  type        = string
  description = "account id for aws"
  default     = "***REMOVED***"
  sensitive = true
}

variable "org_name" {
  type        = string
  description = "organization name"
  default     = "***REMOVED***"
}

variable "base_url" {
  type        = string
  description = "base domain for okta"
  default     = "okta.com"
}

variable "api_token" {
  description = "API token for Okta"
  default     = "***REMOVED***"
  sensitive = true
}


variable "aws_region" {
  type    = string
  default = "us-west-1"
}

variable "default_relay_state" {
  type        = string
  description = "Relay State"
  default     = "https://us-west-1.console.aws.amazon.com/"
}

variable "sso_role_name" {
  type        = string
  description = "sso role name"
  default     = "aws-okta-role"
}

variable "sso_user" {
  type        = string
  description = "sso user name"
  default     = "aws-sso-okta-user"
}

variable "sso_push_group" {
  default     = "AWS Push Group"
  description = "Group for SSO Identity"
}


variable "saml_app_label" {
  type        = string
  description = "Okta Application Name"
  default     = "aws-oauth"
}

variable "oidc_app_label" {
  type        = string
  description = "oidc app label"
  default     = "sso-aws-cli"
}

variable "aws_iam_identity_provider" {
  type        = string
  description = "iam identity provider name"
  default     = "aws-sso-identity-provider"
}

variable "preconfigured_app" {
  type        = string
  description = "preconfigured app"
  default     = "amazon_aws"
}
