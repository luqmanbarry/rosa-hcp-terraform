## AWS: Create Additional SecurityGroup
resource "aws_security_group" "ocp_cluster_sg_config" {
  name = format("%s-%s-%s", var.business_unit, var.openshift_environment, var.cluster_name)
  description = "Security group to allow inbound traffic from OpenShift and CICD/Bastion hosts"
  vpc_id = local.vpc_id

  tags = {
      cluster_name = var.cluster_name
      Name         = format("%s-%s-%s", var.business_unit, var.openshift_environment, var.cluster_name)
    }

  # lifecycle {
  #   create_before_destroy = true
  # }

  # timeouts {
  #   delete = "5m"
  # }
}

## AWS: Allow Inboud from the new OpenShift cluster
resource "aws_security_group_rule" "allow_ingress_from_ocp" {
  depends_on = [ aws_security_group.ocp_cluster_sg_config ]
  type              = "ingress"
  from_port         = var.ocp_sg_inbound_from_port
  to_port           = var.ocp_sg_inbound_to_port
  protocol          = "tcp"
  cidr_blocks       = formatlist(var.vpc_cidr_block)
  security_group_id = aws_security_group.ocp_cluster_sg_config.id
  description       = "Allow inbound from OpenShift cluster"
}

## AWS: Allow inbound from the CICD/Bastion hosts
resource "aws_security_group_rule" "allow_ingress_from_cicd_instance" {
  depends_on = [ aws_security_group.ocp_cluster_sg_config ]
  type              = "ingress"
  from_port         = var.cicd_sg_inbound_from_port
  to_port           = var.cicd_sg_inbound_to_port
  protocol          = "tcp"
  cidr_blocks       = formatlist(var.cicd_instance_cidr)
  security_group_id = aws_security_group.ocp_cluster_sg_config.id
  description       = "Allow inbound from CICD/Bastion hosts"
}