variable "parent_cluster_name" {
  type = string
  default = "dev-parent-ecs-cluster-name"
}

variable "parent_lb_target_group" {
  type = string
  default = "dev-lb-target-group"
}

variable "image_full" {
  description = "Docker image used for deployment - hello world as default"
  type = string
  default = "tutum/hello-world"
}
