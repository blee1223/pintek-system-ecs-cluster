

module "version_label" {
  source = "git@github.com:HHS/acf-ngsc-modules.git//label?ref=v0.1.0"

  delimiter = "_"

  tags = {
    (module.tag_keys.GENERAL.BUSINESS_SERVICE) = module.settings.self.service_name
    (module.tag_keys.GENERAL.VERSION)          = module.settings.self.version
  }
}

module "asg_alarm_label" {
  source = "git@github.com:HHS/acf-ngsc-modules.git//label?ref=v0.1.0"

  context = module.version_label.context

  tags = {
    (module.tag_keys.GENERAL.BUSINESS_SERVICE_COMPONENT) = "alarm"
  }
}

module "target_group_label" {
  source = "git@github.com:HHS/acf-ngsc-modules.git//label?ref=v0.1.0"

  context = module.version_label.context

  tags = {
    (module.tag_keys.GENERAL.BUSINESS_SERVICE_COMPONENT) = "target_group"
  }
}
