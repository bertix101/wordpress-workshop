terraform {
  backend "s3" {
    bucket = "terraform-state-files-0"
    key    = "wp-workshop-state"
    region = "us-east-1"
  }
}