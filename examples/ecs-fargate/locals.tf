locals {
ecs_cluster = {
  name = "arc-ecs-ec2-fargate"
  configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        log_group_name = "arc-poc-cluster-log-group-ec2-fargate"
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

}
