resource "aws_iam_user" "user" {
  name = "example"
  path = "/users"
}

resource "aws_iam_access_key" "user" {
  user    = "${aws_iam_user.user.name}"
  pgp_key = "${var.keybase-user}"
}

resource "aws_iam_login_profile" "user" {
  user    = "${aws_iam_user.user.name}"
  pgp_key = "${var.keybase-user}"
}
