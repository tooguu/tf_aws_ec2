# 変数の設定
variable "aws_access_key" {}
variable "aws_secret_key" {}

# 変数を利用した provider の設定
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "ap-northeast-1"
}
