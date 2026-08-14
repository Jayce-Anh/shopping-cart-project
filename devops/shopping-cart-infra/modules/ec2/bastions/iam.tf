########################### BASTION IAM ##########################

#================= Bastion Instance ==================#
# Roles 
resource "aws_iam_role" "bastion" {
  name = "${var.project.env}-${var.project.name}-bastion"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = ["sts:AssumeRole"]
        Principal = { Service = ["ec2.amazonaws.com"] }
      }
    ]
  })
}

# Attach Policies
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy" "secretsmanager" {
  name = "${var.project.env}-${var.project.name}-bastion-secretsmanager"
  role = aws_iam_role.bastion.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "eks" {
  name = "${var.project.env}-${var.project.name}-bastion-eks"
  role = aws_iam_role.bastion.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster", "eks:ListClusters"]
        Resource = "*"
      }
    ]
  })
}

#================= Bastion Instance Profile ==================#
resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project.env}-${var.project.name}-bastion"
  role = aws_iam_role.bastion.name
}

#================= Scheduler IAM ==================#
# Roles 
resource "aws_iam_role" "scheduler" {
  name = "${var.project.env}-${var.project.name}-bastion-scheduler"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = { Service = "scheduler.amazonaws.com" }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-bastion-scheduler"
  })
}

# Attach Policies
resource "aws_iam_role_policy" "scheduler" {
  name = "${var.project.env}-${var.project.name}-bastion-scheduler"
  role = aws_iam_role.scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:StartInstances", "ec2:StopInstances"]
        Resource = "${aws_instance.bastion.arn}"
      }
    ]
  })
}
