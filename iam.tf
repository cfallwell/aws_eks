data "aws_iam_policy_document" "spa_demo_s3_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:spa-demo:spa-demo"]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "spa_demo_s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [aws_s3_bucket.spa_demo.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.spa_demo.arn}/*"]
  }
}

resource "aws_iam_policy" "spa_demo_s3_access" {
  name   = "${local.name}-spa-demo-s3-access"
  policy = data.aws_iam_policy_document.spa_demo_s3_access.json
  tags   = local.common_tags
}

resource "aws_iam_role" "spa_demo_s3" {
  name               = "${local.name}-spa-demo-s3"
  assume_role_policy = data.aws_iam_policy_document.spa_demo_s3_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "spa_demo_s3_access" {
  role       = aws_iam_role.spa_demo_s3.name
  policy_arn = aws_iam_policy.spa_demo_s3_access.arn
}
