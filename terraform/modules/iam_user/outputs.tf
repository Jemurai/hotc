output "arn" {
  value = "${aws_iam_user.user.arn}"
}

output "access_key_id" {
  value = "${aws_iam_access_key.user.id}"
}

output "secret_access_key" {
  value = "${aws_iam_access_key.user.encrypted_secret}"
}

output "password" {
  value = "${aws_iam_user_login_profile.user.encrypted_password}"
}
