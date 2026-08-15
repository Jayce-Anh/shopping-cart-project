########################### KARPENTER HELM RELEASE ###########################

#=============== Interruption Queue ===============#
resource "aws_sqs_queue" "karpenter" {
  name                      = "${var.project.name}-karpenter-node-interruption"
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-karpenter-node-interruption"
  })
}

#=============== CloudWatch Event Rules ===============#
resource "aws_cloudwatch_event_rule" "karpenter" {
  for_each = {
    spot_interruption = {
      description = "EC2 Spot Instance Interruption Warning"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Spot Instance Interruption Warning"]
      }
    }
    rebalance = {
      description = "EC2 Instance Rebalance Recommendation"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance Rebalance Recommendation"]
      }
    }
    instance_state = {
      description = "EC2 Instance State-change Notification"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance State-change Notification"]
      }
    }
    health_event = {
      description = "AWS Health Event"
      event_pattern = {
        source      = ["aws.health"]
        detail-type = ["AWS Health Event"]
      }
    }
  }

  name          = "${var.helm_eks_cluster}-karpenter-node-interruption-${each.key}"
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-karpenter-node-interruption-${each.key}"
  })
}

#=============== CloudWatch Event Targets ===============#
resource "aws_cloudwatch_event_target" "karpenter" {
  for_each = aws_cloudwatch_event_rule.karpenter

  rule      = each.value.name
  target_id = "KarpenterInterruptionQueueTarget"
  arn       = aws_sqs_queue.karpenter.arn
}

#=============== Karpenter ===============#

resource "helm_release" "karpenter" {
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  namespace        = "karpenter"
  create_namespace = true

  set = [
    {
      name  = "settings.clusterName"
      value = "${var.helm_eks_cluster}"
    },
    {
      name  = "settings.interruptionQueue"
      value = "${var.project.name}-karpenter-node-interruption"
    },
    {
      name  = "controller.resources.requests.cpu"
      value = "1"
    },
    {
      name  = "controller.resources.requests.memory"
      value = "1Gi"
    },
    {
      name  = "controller.resources.limits.cpu"
      value = "1"
    },
    {
      name  = "controller.resources.limits.memory"
      value = "1Gi"
    }
  ]

  timeout = 300

  depends_on = [
    terraform_data.eks_nodes,
    aws_iam_role.karpenter,
    aws_eks_pod_identity_association.karpenter,
    aws_sqs_queue_policy.karpenter,
    aws_cloudwatch_event_target.karpenter,
  ]
}
