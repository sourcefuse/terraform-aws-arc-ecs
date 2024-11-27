aws_account = "1234556"
vpc_id      = "vpc-123455"

environment = "develop"
project     = "arc-poc"

region = "us-east-1"

ecs = {
  cluster_name    = "arc-poc-cluster"
  service_name    = "arc-poc-service"
  repository_name = "1234567.dkr.ecr.us-east-1.amazonaws.com/arc/arc-poc-ecs"

}

task = {
  tasks_desired        = 1
  container_vcpu       = 1024
  container_memory     = 2048
  container_port       = 8100
  container_definition = "container/container_definition.json.tftpl"
}

alb = {
  name                 = "arc-poc-alb"
  alb_port             = 8100
  deregistration_delay = 120
}

autoscaling = {
  metric_name       = "CPUUtilization"
  tasks_desired_min = 1
  tasks_desired_max = 2

  scale_up = {
    threshold = "85"
    cooldown  = "60"
    step_adjustment = [{
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }]
  }

  scale_down = {
    threshold = "20"
    cooldown  = "60"
    step_adjustment = [{
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }]
  }
}
