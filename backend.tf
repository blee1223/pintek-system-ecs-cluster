terraform {
  backend "s3" {
    bucket       = "acf-mock-systems-state" #in mock-shared-services
    key          = "system/dns"
    region       = "us-east-1"
    role_arn     = "arn:aws:iam::390778175045:role/acf-infrastructure-engineer" #mock-shared-services
    session_name = "terraform-infrastructure-engineer"
  }
}

