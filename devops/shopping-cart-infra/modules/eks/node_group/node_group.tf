##################################### NODE GROUP #########################################

#================== Node Group ==================#
resource "aws_eks_node_group" "node_groups" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.project.env}-${var.project.name}-${local.eks_label}-${each.key}-node-group"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = each.value.subnet_ids
  ami_type        = lookup(each.value, "ami_type", "AL2023_x86_64_STANDARD")
  labels          = lookup(each.value, "labels", null)
  release_version = lookup(
    each.value,
    "release_version",
    data.aws_ssm_parameter.eks_ami_release_version[lookup(each.value, "ami_type", "AL2023_x86_64_STANDARD")].value
  )
  capacity_type  = lookup(each.value, "capacity_type", "ON_DEMAND")
  instance_types = lookup(each.value, "instance_types", null)

  # Scaling Config  
  scaling_config {
    min_size     = lookup(each.value, "min_size", 1)
    max_size     = lookup(each.value, "max_size", 1)
    desired_size = lookup(each.value, "desired_size", 1)
  }

  update_config {
    max_unavailable = lookup(each.value, "max_unavailable", 1)
  }

  # Launch Template 
  launch_template {
    id      = aws_launch_template.node_groups[each.key].id
    version = aws_launch_template.node_groups[each.key].latest_version
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # Taints 
  dynamic "taint" {
    for_each = lookup(each.value, "taints", [])
    iterator = taint

    content {
      key    = taint.value.key
      value  = lookup(taint.value, "value", "")
      effect = taint.value.effect
    }
  }

  # Wait for essential add-ons before creating node groups:
  depends_on = [
    aws_iam_role_policy_attachment.node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_group_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_group_AmazonSSMManagedInstanceCore,
    aws_iam_role_policy.node_group_kms,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy,
  ]

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

#================== Node Group Launch Template ==================#
resource "aws_launch_template" "node_groups" {
  for_each  = var.node_groups
  name      = "${var.project.env}-${var.project.name}-${local.eks_label}-${each.key}-node-group"
  user_data = can(data.cloudinit_config.node_groups[each.key]) ? data.cloudinit_config.node_groups[each.key].rendered : null
  key_name  = lookup(each.value, "key_name", null)

  # Block Device Mappings
  block_device_mappings {
    device_name = lookup(each.value, "device_name", "/dev/xvda")
    ebs {
      volume_size           = lookup(each.value, "disk_size", "20")
      volume_type           = lookup(each.value, "disk_type", "gp3")
      delete_on_termination = lookup(each.value, "delete_on_termination", true)
      encrypted             = var.enable_kms
      kms_key_id            = var.kms_key_arn
    }
  }

  dynamic "block_device_mappings" {
    for_each = can(each.value.block_device_mappings) ? each.value.block_device_mappings : []

    content {
      device_name = block_device_mappings.value.device_name
      ebs {
        volume_size           = lookup(block_device_mappings.value, "disk_size", "20")
        volume_type           = lookup(block_device_mappings.value, "disk_type", "gp3")
        snapshot_id           = lookup(block_device_mappings.value, "snapshot_id", null)
        delete_on_termination = lookup(block_device_mappings.value, "delete_on_termination", true)
      }
    }
  }

  # Network Interfaces
  network_interfaces {
    security_groups = distinct(concat(
      [
        aws_eks_cluster.eks.vpc_config.0.cluster_security_group_id,
        aws_security_group.node_groups[each.key].id
      ],
      lookup(each.value, "security_group_ids", []),
    ))
    delete_on_termination       = true
    associate_public_ip_address = lookup(each.value, "associate_public_ip_address", false)
  }

  # Metadata Options
  metadata_options {
    http_endpoint               = try(each.value.metadata.http_endpoint, "enabled")
    http_tokens                 = try(each.value.metadata.http_tokens, "required") # switch to "optional" if your services use old version of AWS SDK (Allows both IMDSv1 + IMDSv2)
    http_put_response_hop_limit = try(each.value.metadata.http_put_response_hop_limit, 2)
    instance_metadata_tags      = try(each.value.metadata.instance_metadata_tags, "disabled")
  }

  # Tag Specifications
  dynamic "tag_specifications" {
    for_each = ["instance", "volume"]

    content {
      resource_type = tag_specifications.value

      tags = merge(var.tags, lookup(each.value, "tags", {}), {
        Name           = "${var.project.env}-${var.project.name}-${local.eks_label}-${each.key}-node"
        LaunchTemplate = "${var.project.env}-${var.project.name}-${local.eks_label}-${each.key}-node-group"
      })
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${local.eks_label}-${each.key}-node-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

#================== Node Group Cloud-Init Config ==================#
data "cloudinit_config" "node_groups" {
  for_each = {
    for k, v in var.node_groups :
    k => v.block_device_mappings
    if can(v.block_device_mappings)
  }

  base64_encode = true
  gzip          = false

  dynamic "part" {
    for_each = {
      for k, v in each.value :
      k => v
      if !can(v.snapshot_id)
    }

    content {
      content_type = "text/x-shellscript"
      content      = <<EOF
      mkfs -t ext4 ${part.value.device_name}
      EOF
    }
  }

  dynamic "part" {
    for_each = each.value

    content {
      content_type = "text/x-shellscript"
      content      = <<EOF
      mkdir -p ${part.value.mount_path}
      mount ${part.value.device_name} ${part.value.mount_path}
      echo "${part.value.device_name} ${part.value.mount_path} ext4  defaults,nofail,discard,comment=cloudconfig 0 0" >> /etc/fstab
      EOF
    }
  }
}

