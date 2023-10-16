data "aws_iam_policy_document" "ecs" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "ecs_profile" {
  name = join("_", [var.project_name, "ecs"])
  role = aws_iam_role.ecs_role.name
}

resource "aws_iam_role" "ecs_role" {
  name               = "${var.project_name}-ecs"
  assume_role_policy = data.aws_iam_policy_document.ecs.json
}

resource "aws_iam_role_policy" "exec_command_policy" {
  name   = "${var.project_name}-exec"
  role   = aws_iam_role.ecs_role.id
  policy = data.aws_iam_policy_document.exec_command_document.json
}

resource "aws_iam_role_policy" "ecs_generic_policy" {
  name   = "${var.project_name}-ecs_policy"
  role   = aws_iam_role.ecs_role.id
  policy = data.aws_iam_policy_document.ecs_policy_document.json
}

resource "aws_iam_role_policy" "ecs_policy" {
  name   = "${var.project_name}-get_secrets"
  role   = aws_iam_role.ecs_role.id
  policy = data.aws_iam_policy_document.list_secrets.json
}

resource "aws_iam_role_policy_attachment" "ecs_policy_att" {
  role = aws_iam_role.ecs_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

data "aws_iam_policy_document" "exec_command_document" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:ExecuteCommand",
    ]
    resources = [
      aws_ecs_cluster.ecs_cluster.arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "list_secrets" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
      "ec2:DescribeTags",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
    ]
    resources = [
      aws_ecs_cluster.ecs_cluster.arn,
    ]
  }
  statement {
    actions = [
      "kms:Decrypt",
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      aws_ecs_cluster.ecs_cluster.arn,
    ]
  }
}

data "aws_iam_policy_document" "ecs_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:Get*",
      "sqs:List*",
      "sqs:PurgeQueue",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:SetQueueAttributes",
      "s3:DeleteObject*",
      "s3:Get*",
      "s3:List*",
      "s3:PutBucketNotification",
      "s3:PutObject*",
      "s3:ReplicateObject",
      "s3:RestoreObject",
      "ecr:Describe*",
      "ecr:Get*",
      "ecr:List*",
      "ecr:PutImage",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "cloudtrail:LookupEvents",
      "iam:CreateServiceLinkedRole"
    ]
    resources = [
      "*"
    ]
  }
}
