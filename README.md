# okta-aws-federation

This repo is my hands on lab for configuring AWS SSO with Okta using SAML 2.0 and Terraform. The goal is to simulate & let Okta users sign in to AWS and assume predefined IAM roles, while keeping all of the identity and IAM wiring declared and repeatable in code.

## Overview

The Terraform configuration automates the setup of the necessary components in both AWS and Okta to establish a trust relationship.

*   **In AWS:**
    *   Creates a SAML Identity Provider that trusts your Okta organization.
    *   Creates an IAM Role that federated users can assume.
    *   Attaches a sample IAM policy (`sso-eks-policy`) to the role, granting read-only access to Amazon EKS resources.
    *   Creates a service IAM User (`aws-sso-okta-user`) with credentials that Okta uses to list available IAM roles in your AWS account.

*   **In Okta:**
    *   Creates a pre-configured SAML 2.0 application for AWS.
    *   Configures the application settings to map Okta identities to AWS IAM Roles.
    *   Creates an Okta group (`AWS Push Group`) to manage user access.
    *   Assigns the group and its members to the AWS application.

## Prerequisites

*   Terraform v1.0+
*   An AWS account with permissions to create the IAM resources defined in `iam.tf`.
*   An Okta organization with administrative access.
*   An Okta API Token.

## Deployment Steps

1.  **Clone the Repository**
    ```sh
    git clone https://github.com/ddc-96/okta-aws-federation.git
    cd okta-aws-federation/terraform
    ```

2.  **Configure Variables**
    Create a file named `terraform.tfvars` in the `terraform/` directory. Populate it with the required values for your AWS and Okta environments.

    *Example `terraform.tfvars`:*
    ```hcl
    # AWS Configuration
    aws_account_id = "YOUR_AWS_ACCOUNT_ID"

    # Okta Configuration
    org_name       = "your-org-name" # e.g., "dev-123456"
    base_url       = "okta.com" # or your custom domain like "yourcompany.com"
    api_token      = "YOUR_OKTA_API_TOKEN"
    ```
    **Note:** The configuration in `okta.tf` includes hardcoded user IDs in the `okta_group_memberships` resource. You must replace these with the actual IDs of your Okta users.

3.  **Initialize Terraform**
    This command downloads the necessary provider plugins (AWS and Okta).
    ```sh
    terraform init
    ```

4.  **Review and Apply Configuration**
    Run `terraform plan` to see the resources that will be created. If the plan is acceptable, apply the configuration.
    ```sh
    terraform plan
    terraform apply
    ```

## Post-Deployment Configuration

After running `terraform apply`, you must perform a manual step to allow Okta to connect to your AWS account for role provisioning.

1.  **Retrieve IAM User Credentials**
    The Terraform configuration creates an IAM user (default name: `aws-sso-okta-user`) and an associated access key.
    *   In the AWS Management Console, navigate to **IAM > Users**.
    *   Select the `aws-sso-okta-user`.
    *   Go to the **Security credentials** tab.
    *   Under "Access keys", click **Create access key**, select "Third-party service", and follow the prompts to create and retrieve the **Access key ID** and **Secret access key**.

2.  **Configure API Integration in Okta**
    *   Log in to your Okta admin dashboard.
    *   Go to **Applications > Applications** and select the application created by Terraform (default name: `aws-oauth`).
    *   Select the **Provisioning** tab.
    *   Click **Configure API Integration** and check the box for **Enable API integration**.
    *   Paste the **Access Key ID** and **Secret Access Key** from the previous step into the respective fields.
    *   Click **Test API Credentials** to verify the connection.
    *   Click **Save**.

3.  **Enable Provisioning to App**
    *   While still on the **Provisioning** tab, select **To App** from the settings panel on the left.
    *   Click **Edit** and enable **Create Users**, **Update User Attributes**, and **Deactivate Users**.
    *   Click **Save**.

Your Okta-AWS federation is now configured. Users assigned to the `AWS Push Group` in Okta can now sign in to the AWS console.

## Terraform Variables

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `aws_account_id` | Your AWS account ID. | `string` | - | **Yes** (Sensitive) |
| `org_name` | Your Okta organization name (e.g., "dev-123456"). | `string` | - | **Yes** |
| `base_url` | Your base domain for Okta (e.g., "okta.com"). | `string` | `okta.com` | No |
| `api_token` | API token for Okta. | `string` | - | **Yes** (Sensitive) |
| `aws_region` | The AWS region to operate in. | `string` | `us-west-1` | No |
| `default_relay_state`| The AWS Console URL to redirect to after successful login. | `string` | `https://us-west-1.console.aws.amazon.com/` | No |
| `sso_role_name` | The name of the IAM role for SSO. | `string` | `aws-okta-role` | No |
| `sso_user` | The name of the IAM service user for Okta API integration. | `string` | `aws-sso-okta-user` | No |
| `sso_push_group`| The name for the Okta group used to assign users to AWS. | `string` | `AWS Push Group` | No |
| `saml_app_label` | The display name for the Okta SAML application. | `string` | `aws-oauth` | No |
| `aws_iam_identity_provider`| The name for the IAM SAML identity provider in AWS. | `string` | `aws-sso-identity-provider` | No |
| `preconfigured_app` | The Okta pre-configured application template name. | `string` | `amazon_aws` | No |
