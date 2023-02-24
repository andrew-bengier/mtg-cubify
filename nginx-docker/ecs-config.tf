data "aws_iam_policy_document" "bnfd_iam_policy_ecs" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "bnfd_iam_role" {
  assume_role_policy = data.aws_iam_policy_document.bnfd_iam_policy_ecs.json
  name               = "${terraform.workspace}-ecs-agent"
}

resource "aws_iam_policy_attachment" "bnfd_iam_policy_attachment" {
  name       = "${terraform.workspace}-ecs-agent-policy-attachment"
  roles      = [aws_iam_role.bnfd_iam_role.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "bnfd_iam_instance_profile" {
  name = "${terraform.workspace}-ecs-agent"
  role = aws_iam_role.bnfd_iam_role.name
}

resource "tls_private_key" "bnfd_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bnfd_ssh_key" {
  public_key = tls_private_key.bnfd_tls_key.public_key_openssh
  key_name   = "${terraform.workspace}-name"

  provisioner "local-exec" {
    command = "echo '${tls_private_key.bnfd_tls_key.private_key_pem}' > ./myKey.pem"
  }
}

resource "aws_launch_configuration" "bnfd_ecs_launch_config" {
  image_id             = "ami-0cd7323ab3e63805f" # Amazon linux 2 kernel 5.10 (64bit (arm))
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.bnfd_iam_instance_profile.name
  security_groups      = [aws_security_group.load_balancer_security_group.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.bnfd_ecs_cluster.name} >> /etc/ecs/ecs.config"

  key_name                    = aws_key_pair.bnfd_ssh_key.key_name
  associate_public_ip_address = true 

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bnfd_autoscaling_group" {
  max_size             = 2
  min_size             = 1
  name                 = "${terraform.workspace}-autoscaling-group"
  vpc_zone_identifier  = aws_subnet.public_subnets[*].id
  launch_configuration = aws_launch_configuration.bnfd_ecs_launch_config.name
}

resource "aws_ecs_cluster" "bnfd_ecs_cluster" {
  name = "${terraform.workspace}-ecs-cluster"
}
