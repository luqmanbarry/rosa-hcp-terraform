## AWS: VPC
data "aws_vpc" "get_vpc" {
  tags = local.tags_query
}

## AWS: Private Subnets
data "aws_subnets" "get_private_subnet_ids" {
  tags = local.tags_query

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

data "aws_subnets" "get_public_subnet_ids" {
  tags = local.tags_query

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

## AWS: Availability Zones
data "aws_subnet" "get_availability_zones" {
  for_each  = toset(data.aws_subnets.get_private_subnet_ids.ids)
  id        = each.value
}

## AWS: Additional Security Groups
data "aws_security_groups" "aws_additional_security_group_ids" {
  tags = local.tags_query
}

data "aws_security_group" "aws_additional_security_groups" {
  for_each  = toset(data.aws_security_groups.aws_additional_security_group_ids.ids)
  id        = each.value
}

## AWS: HostedZone ID
data "aws_route53_zone" "hosted_zone" {
  depends_on = [ data.aws_vpc.get_vpc ]
  name    = var.base_dns_domain
  vpc_id  = local.vpc_id
}

## Local Filesystem: Write combined tfvars to file
resource "local_file" "write_output" {
  content = local.final_tfvars_content
  filename = local.final_tfvars_path
}
