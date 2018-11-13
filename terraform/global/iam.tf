resource "aws_iam_account_password_policy" "hotc" {
  minimum_password_length        = 12
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  password_reuse_prevention      = 5
  max_password_age               = 180
}

resource "aws_iam_user" "example" {
  name = "example"
  path = "/users"
}

resource "aws_iam_access_key" "example" {
  user = "${aws_iam_user.example.name}"
  pgp_key = "${var.keybase-user}"
}

resource "aws_iam_login_profile" "example" {
  user = "${aws_iam_user.example.name}"
  pgp_key = "${var.keybase-user}"
}

output "example-access-key-id" {
  value = "${aws_iam_access_key.example.id}"
}

output "example-secret-access-key" {
  value = "${aws_iam_access_key.example.encrypted_secret}"
}

output "example-password" {
  value = "${aws_iam_user_login_profile.example.encrypted_password}"
}
