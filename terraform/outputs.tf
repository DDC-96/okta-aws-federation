output "sso_access_key_id" {
  value       = aws_iam_access_key.sso_key.id
  description = "The access key ID for the sso_user"
  sensitive = true
}

output "sso_secret_access_key" {
  value       = aws_iam_access_key.sso_key.secret
  description = "The secret access key for the sso_user"
  sensitive = true
}

# Steps to delete the key
# 1 
# aws iam list-access-keys --user-name <USRNAME> --output json
# 2 
# aws iam delete-access-key --user-name <USRNAME> --access-key-id <KEY>
