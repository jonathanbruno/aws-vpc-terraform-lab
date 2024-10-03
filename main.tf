terraform {
  required_version = ">= 0.12"

   backend "s3" {
    bucket = "jb-terraform-bucket-vpc"
    key    = "terraform/state.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      managed-by = "terraform"
    }
  }
}
