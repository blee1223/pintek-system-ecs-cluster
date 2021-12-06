

module "project_version_label" {
  source = "git@github.com:blee1223/pintek-modules.git//label"

  delimiter = "_"

  tags = {
    (module.tag_keys.GENERAL.BUSINESS_SERVICE) = module.settings.self.service_name
    (module.tag_keys.GENERAL.VERSION)          = module.settings.self.version
  }
}

module "asg_alarm_label" {
  source = "git@github.com:blee1223/pintek-modules.git//label"

  context = module.project_version_label.context

  tags = {
    (module.tag_keys.GENERAL.BUSINESS_SERVICE_COMPONENT) = "alarm"
  }
}

module "target_group_label" {
  source = "git@github.com:blee1223/pintek-modules.git//label"

  context = module.project_version_label.context

  tags = {
    (module.tag_keys.GENERAL.BUSINESS_SERVICE_COMPONENT) = "target_group"
  }
}
