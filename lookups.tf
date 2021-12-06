

data "aws_ssm_parameter" "ami" {
  name = module.settings.self.cluster_config.ecs_ami_ssm_key
}


data "aws_vpc" "self" {
  filter {
    name   = "tag:${module.tag_keys.GENERAL.KEY}"
    values = [module.settings.self.vpc_key]
  }
}

#search for subnet where the cluster will be place
data "aws_subnet_ids" "cluster" {
  vpc_id = local.vpc_id

  filter {
    name   = "tag:${module.tag_keys.GENERAL.KEY}"
    values = [module.settings.self.cluster_config.subnet_name]
  }
}

data "aws_security_groups" "gss" {
  tags = {
    (module.tag_keys.GENERAL.SYSTEM) = module.tag_values.SYSTEMS.GSS
  }

  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

data "aws_security_group" "gss" {
  for_each = toset(data.aws_security_groups.gss.ids)

  id = each.value
}



locals {

  vpc_id = data.aws_vpc.self.id

  sg_names = ["shared-services-client", "linux-client", "management-client"]
  gss_security_group_ids = [
    for sg in values(data.aws_security_group.gss) :
      sg.id
    if contains(local.sg_names, lookup(sg.tags, module.tag_keys.GENERAL.KEY, false)) == true
  ]  
}
