provider "aws" {
  region = module.settings.self.region

  assume_role {
    role_arn = "arn:aws:iam::${module.settings.self.account_id}:role/${module.settings.self.infrastructure_engineer_role_name}"
  }
}

provider "aws" {
  region = module.settings.self.region
  alias  = "enterprise_architect"

  assume_role {
    role_arn = "arn:aws:iam::${module.settings.self.account_id}:role/${module.settings.self.enterprise_architect}"
  }
}

