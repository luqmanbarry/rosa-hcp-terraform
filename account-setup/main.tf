
module "rosa-hcp_vpc" {
  source  = "terraform-redhat/rosa-hcp/rhcs//modules/vpc"
  version = "1.6.1-prerelease.2"

  name_prefix         = var.cluster_name
  vpc_cidr            = var.vpc_cidr_block
  availability_zones_count	 = 3

  tags = merge(
    {
      Name         = var.cluster_name
      cluster_name = var.cluster_name
    },
    var.additional_tags
  )
}

resource "aws_route53_zone" "base_dns_domain" {
  name = var.base_dns_domain

  vpc {
    vpc_id = local.vpc_id
  }

  lifecycle {
    ignore_changes = [ vpc ]
  }
}

# data "aws_route53_zone" "base_dns_route53_zone" {
#   depends_on = [ module.rosa-hcp_vpc ]
#   name         = var.base_dns_domain
# }

# resource "aws_route53_vpc_association_authorization" "vpc_route53_zone_authorization" {
#   depends_on = [ data.aws_route53_zone.base_dns_route53_zone ]
#   zone_id = aws_route53_zone.base_dns_domain.id
#   vpc_id  = local.vpc_id
# }

# resource "aws_route53_zone_association" "vpc_zone_association" {
#   depends_on = [ aws_route53_vpc_association_authorization.vpc_route53_zone_authorization ]
#   zone_id = aws_route53_vpc_association_authorization.vpc_route53_zone_authorization.zone_id
#   vpc_id  = aws_route53_vpc_association_authorization.vpc_route53_zone_authorization.vpc_id
# }

# TODO: Add code to provision bastion host and apply inbound SG rules
