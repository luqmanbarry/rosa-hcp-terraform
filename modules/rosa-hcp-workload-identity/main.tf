locals {
  roles = {
    for role in var.roles : role.name => role
  }

  oidc_provider_hostpath = replace(var.oidc_provider_url, "https://", "")
}

data "aws_iam_policy_document" "assume_role" {
  for_each = local.roles

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_hostpath}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  for_each = local.roles

  name                 = each.value.name
  description          = try(each.value.description, null)
  max_session_duration = try(each.value.max_session_duration, 3600)
  path                 = try(each.value.path, "/")
  assume_role_policy   = data.aws_iam_policy_document.assume_role[each.key].json

  tags = merge(
    var.default_tags,
    {
      managed_by           = "terraform"
      workload_identity    = "true"
      kubernetes_namespace = each.value.namespace
      service_account      = each.value.service_account_name
    },
    try(each.value.tags, {}),
  )
}

resource "aws_iam_role_policy" "inline" {
  for_each = {
    for name, role in local.roles : name => role
    if length(trimspace(try(role.inline_policy_json, ""))) > 0
  }

  name   = "${each.key}-inline"
  role   = aws_iam_role.this[each.key].id
  policy = each.value.inline_policy_json
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = {
    for item in flatten([
      for role_name, role in local.roles : [
        for policy_arn in try(role.managed_policy_arns, []) : {
          key        = "${role_name} ${policy_arn}"
          role_name  = role_name
          policy_arn = policy_arn
        }
      ]
    ]) : item.key => item
  }

  role       = aws_iam_role.this[each.value.role_name].name
  policy_arn = each.value.policy_arn
}
