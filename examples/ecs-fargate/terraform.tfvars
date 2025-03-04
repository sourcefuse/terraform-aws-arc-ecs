region      = "us-east-1"
environment = "develop"
namespace   = "arc"
vpc_name =  "arc-poc"
subnet_names = ["arc-poc-db-az1", "arc-poc-db-az2"]

ecs_cluster = {
  name = "arc-ecs-fargate-poc"
  configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        log_group_name = "arc-poc-cluster-log-group-fargate"
      }
    }
  }
  create_cloudwatch_log_group = true
  service_connect_defaults    = {}
  settings                    = []
}

capacity_provider = {
  autoscaling_capacity_providers = {}
  use_fargate                    = true
  fargate_capacity_providers = {
    fargate_cp = {
      name = "FARGATE"
    }
  }
}

ecs_service = {
  cluster_name             = "arc-ecs-module-poc"
  service_name             = "arc-ecs-module-service-poc"
  repository_name          = "12345.dkr.ecr.us-east-1.amazonaws.com/arc/arc-poc-ecs"
  ecs_subnets              = ["subnet-1234567890", "subnet-1234567890"]
  enable_load_balancer     = true
  aws_lb_target_group_name = "arc-poc-alb-tg"
  create_service           = true
}

task = {
  tasks_desired        = 1
  launch_type          = "FARGATE"
  network_mode         = "awsvpc"
  compatibilities      = ["FARGATE"]
  container_port       = 80
  container_memory     = 1024
  container_vcpu       = 256
  container_definition = "container/container_definition.json.tftpl"
}

lb = {
  name              = "arc-poc-alb"
  listener_port     = 80
  security_group_id = "sg-1234567890"
}

cidr_blocks = null

alb = {
  name       = "arc-poc-alb"
  internal   = false
  port       = 80
  create_alb = true
}

alb_target_group = [
  {
    name        = "arc-poc-alb-tg"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = "vpc-1234567890"
    target_type = "ip"
    health_check = {
      enabled = true
      path    = "/"
    }
    stickiness = {
      enabled = true
      type    = "lb_cookie"
    }
  }
]

listener_rules = []
