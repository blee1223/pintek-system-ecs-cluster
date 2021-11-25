
module "constants" {
  source = "git@github.com:HHS/acf-ngsc-modules.git//constants?ref=v0.1.0"
}

module "tag_keys" {
  source = "git@github.com:HHS/acf-ngsc-modules.git//constants/tag_key?ref=v0.1.0"
}

module "tag_values" {
  source = "git@github.com:HHS/acf-ngsc-modules.git//constants/tag_value?ref=v0.1.0"
}

module "settings" {
  source = "git@github.com:HHS/acf-ngsc-modules.git//workspace_settings?ref=v0.1.0"

  default_contents = file("${path.module}/default_config.yaml")
  workspace_contents = file("${path.module}/workspaces/${terraform.workspace}.yaml")
}


data "template_file" "user_data" {
  template = file("${path.module}/user-data.tpl")

  vars = {
    cluster_name = module.settings.self.cluster_config.name
  }
}

module "security_groups" {
  source = "git@github.com:HHS/acf-ngsc-network-modules.git//vpc/security_group?ref=v0.0.4"

  for_each = { for config in module.settings.self.security_groups_config : config.name => config }

  name      = each.value.name
  namespace = module.settings.self.vpc_key
  rules     = each.value.rules
  vpc_id    = data.aws_vpc.self.id

  context = module.version_label.context
  tags = {
    (module.tag_keys.GENERAL.BUSINESS_SERVICE_COMPONENT) = module.tag_values.BUSINESS_SERVICE_COMPONENTS.SECURITY_GROUP
  }
}

module "iam_role" {
  source = "git@github.com:HHS/acf-ngsc-modules.git//iam_role?ref=v0.1.0"

  providers = {
    aws = aws.enterprise_architect
  }

  name                     = module.settings.self.role_config.name
  assume_role_policy       = module.settings.self.role_config.policy_config.assume_role_policy
  managed_policy_arns      = module.settings.self.role_config.policy_config.managed_policy_arns
  inline_policies          = module.settings.self.role_config.policy_config.inline_policies

  tags = module.version_label.tags
}

resource "aws_iam_instance_profile" "ecs_instance" {
  provider = aws.enterprise_architect

  name = module.settings.self.role_config.name
  role = module.iam_role.self.name

  lifecycle { create_before_destroy = true }
}


resource "aws_ecs_cluster" "ecs_cluster" {
  name = module.settings.self.cluster_config.name
}


# the target group for the cluster
resource "aws_alb_target_group" "cluster_tg" {
  name     = module.settings.self.cluster_config.target_group.name
  protocol = module.settings.self.cluster_config.target_group.protocol
  port     = module.settings.self.cluster_config.target_group.port
  vpc_id   = local.vpc_id

  health_check {
    path = "/"
  }

  tags = module.target_group_label.tags
}

module "ecs_cluster" {
  source = "git@github.com:HHS/acf-ngsc-system-modules.git//autoscaling/ec2?ref=v0.0.2"

  providers = {
    aws = aws
  }

  name                  = module.settings.self.cluster_config.name
  lc_name               = "${module.settings.self.cluster_config.name}_lc"
  user_data             = data.template_file.user_data.rendered
  instance_type         = module.settings.self.cluster_config.instance_type
  key_pair_name         = module.settings.self.cluster_config.key_pair_name
  instance_profile_name = aws_iam_instance_profile.ecs_instance.name
  ami                   = data.aws_ssm_parameter.ami.value
  health_check_type     = "EC2"
  asg_min               = module.settings.self.cluster_config.autoscaling.minimum
  asg_max               = module.settings.self.cluster_config.autoscaling.maximum
  asg_desired_capacity  = module.settings.self.cluster_config.autoscaling.desired_capacity
  target_group_arn      = aws_alb_target_group.cluster_tg.arn

  subnet_ids         = data.aws_subnet_ids.cluster.ids
  security_group_ids = concat(local.gss_security_group_ids, local.cluster_security_group_ids)

  context = module.version_label.context
  tags = {
    (module.tag_keys.GENERAL.BUSINESS_SERVICE_COMPONENT) = module.tag_values.BUSINESS_SERVICE_COMPONENTS.EC2
  }
}


locals {

  cluster_security_group_ids = [
    for sg in values(module.security_groups) :
      sg.self.id
    if contains(module.settings.self.cluster_config.security_group_names, sg.self.tags[module.tag_keys.GENERAL.KEY]) == true
  ]
}
