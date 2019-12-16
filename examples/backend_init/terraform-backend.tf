module "odc_test_stage_backend_label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.4.0"
  namespace  = var.backend_name
  stage      = var.environment
  name       = "backend"
  delimiter  = "-"
}

# terraform state file setup
# create an S3 bucket to store the state file in
resource "aws_s3_bucket" "terraform-state-storage-s3" {
    bucket = "${module.odc_test_stage_backend_label.id}-tfstate"
    region = "${var.region}"
    acl = "private"

    versioning {
      enabled = true
    }

    # Uncomment this to prevent unintended destruction of state
    # lifecycle {
    #   prevent_destroy = true
    # }

    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm     = "AES256"
        }
      }
    }
 
    tags = {
      Name = "S3 Remote Terraform State Store for ${module.odc_test_stage_backend_label.id}"
    }      
}


# The terraform lock database resource
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "${module.odc_test_stage_backend_label.id}-terraform-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
      name = "LockID"
      type = "S"
  }
  tags = {
    Name = "DynamoDB Terraform State Lock Table for ${module.odc_test_stage_backend_label.id}"
  }
}

output "tf-state-bucket" {
  value = "${aws_s3_bucket.terraform-state-storage-s3.*.id}"
}

output "dynamodb_table" {
  value = "${aws_dynamodb_table.terraform_state_lock.*.name}"
}
