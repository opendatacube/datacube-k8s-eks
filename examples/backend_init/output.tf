output "tf-state-bucket" {
  value = "${aws_s3_bucket.terraform-state-storage-s3.*.id}"
}

output "dynamodb_table" {
  value = "${aws_dynamodb_table.terraform_state_lock.*.name}"
}