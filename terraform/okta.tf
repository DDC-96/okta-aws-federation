# Okta SAML Application "Environment" Configuration / This will be using SAML 2.0 to Auth users with AWS 
resource "okta_app_saml" "sso" {
  accessibility_self_service = false
  app_links_json = jsonencode({
    login = true
  })
  assertion_signed        = false
  auto_submit_toolbar     = true
  default_relay_state     = var.default_relay_state # AWS Region for URL sign in
  hide_ios                = false
  hide_web                = false
  honor_force_authn       = false
  implicit_assignment     = false
  label                   = var.saml_app_label
  preconfigured_app       = var.preconfigured_app
  response_signed         = false
  saml_version            = "2.0"
  status                  = "ACTIVE"
  user_name_template      = "$${source.login}"
  user_name_template_type = "BUILT_IN"
}

# Build AWS {Identity Provider} / This will help the Okta Application federate with AWS
resource "aws_iam_saml_provider" "identity_provider_config" {
  name                   = var.aws_iam_identity_provider
  saml_metadata_document = okta_app_saml.sso.metadata
}

# Configure SAML Application
resource "okta_app_saml_app_settings" "sso_settings" {
  app_id = okta_app_saml.sso.id
  settings = jsonencode({
    appFilter           = "okta"
    awsEnvironmentType  = "aws.amazon"
    groupFilter         = "aws_(?{{accountid}}\\d+)_(?{{role}}[a-zA-Z0-9+=,.@\\-_]+)"
    identityProviderArn = aws_iam_saml_provider.identity_provider_config.arn # IAM identity provider's arn created before
    joinAllRoles        = false
    loginURL            = "https://console.aws.amazon.com/"
    roleValuePattern    = "arn:aws:iam::$${accountid}:saml-provider/OKTA,arn:aws:iam::$${accountid}:role/$${role}"
    sessionDuration     = 3600
    useGroupMapping     = false
    }
  )
}

# Build Okta Push Group
resource "okta_group" "sso_group" {
  name        = var.sso_push_group
  description = "AWS SSO Push Group"
}

# Below block should be implemented after adding secret and access keys into aws application under provisioning
# Assign the Okta Group to the SAML Application / Manually map the Role and SAML User Roles in Okta 
resource "okta_app_group_assignment" "sso_group" {
  app_id   = okta_app_saml.sso.id
  group_id = okta_group.sso_group.id

  profile = jsonencode({
    role = null
  })
}

# Assign users to the AWS SSO Push Group, defined by Web URL UUID
resource "okta_group_memberships" "manual_imported_users" {
  group_id = okta_group.sso_group.id
  users = [
    "00unhtmvixIWvcLSS697", # Xavier Lopez
    "00unkze9wmZIQbQzW697", # Carlos Troy
  ]
}


# Create an Okta User
# resource "okta_user" "harry" {
#   department      = "Cloud"
#   display_name    = "Harry Ford"
#   email           = ""
#   employee_number = "12344567"
#   first_name      = "Harry"
#   last_name       = "Ford"
#   login           = ""
#   second_email    = "mail@mail.com"
# }

# # Assign the User to the Group
# resource "okta_group_memberships" "automated_user_creation" {
#   group_id = okta_group.sso_group.id
#   users = [
#     okta_user.harry.id,
#     "", 
#   ]
# }
