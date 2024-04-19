module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name  = var.cluster_name
  cidr  = var.vpc_cidr_block

  azs             = [
    format("%sa", var.aws_region),
    format("%sb", var.aws_region),
    format("%sc", var.aws_region)
  ]

  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway   = true
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
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
#   depends_on = [ module.vpc ]
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
