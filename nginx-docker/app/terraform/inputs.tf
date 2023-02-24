data "aws_ssm_parameter" "parent_ecs_cluster_name" {
  name = var.parent_cluster_name
}

data "aws_ssm_parameter" "lb_target_group" {
  name = var.parent_lb_target_group
}
