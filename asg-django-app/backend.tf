terraform {
    backend "s3" {
    bucket = "deom-for-tfstate-files-0128"
    encrypt = true
    key = "dev/terraform-cicd/terraform.tfstate"
    region = "us-east-2"
    use_lockfile = true
  }
}
