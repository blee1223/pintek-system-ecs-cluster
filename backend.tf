terraform {
  backend "s3" {
    bucket       = "pintek-mock-systems-state" #in mock-shared-services
    key          = "system/ecs"
    region       = "us-east-1"
    role_arn     = "arn:aws:iam::390778175045:role/pintek-infrastructure-engineer" #mock-shared-services
    session_name = "terraform-infrastructure-engineer"
  }
}

