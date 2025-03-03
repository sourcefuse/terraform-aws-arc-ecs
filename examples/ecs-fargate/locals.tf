locals {
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
  ecs_subnets              = data.aws_subnets.private.ids
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
  security_group_id = module.alb.security_group_ids
}

cidr_blocks = null

load_balancer_config = {
    name                                        = "arc-load-balancer"
    type                                        = "application"
    enable_deletion_protection                  = false
    enable_cross_zone_load_balancing            = true
    enable_http2                                = false
    enable_xff_client_port                      = false
    enable_zonal_shift                          = false
    preserve_host_header                        = false
    enable_tls_version_and_cipher_suite_headers = false

    subnet_mapping = [
      {
        subnet_id = data.aws_subnets.private.ids[0]
      },
      {
        subnet_id = data.aws_subnets.private.ids[1]
      }
    ]

  }

  security_group_data = {
    create      = true
    description = "Security Group for alb"
    ingress_rules = [
      {
        description = "Allow VPC traffic"
        cidr_block  = "0.0.0.0/0" # Changed to string
        from_port   = 0
        ip_protocol = "tcp"
        to_port     = 443
      },
      {
        description = "Allow traffic from self"
        self        = true
        from_port   = 80
        ip_protocol = "tcp"
        to_port     = 80
      },
    ]
    egress_rules = [
      {
        description = "Allow all outbound traffic"
        cidr_block  = "0.0.0.0/0" # Changed to string
        from_port   = -1
        ip_protocol = "-1"
        to_port     = -1
      }
    ]
  }

  target_group_config = {
    name        = "arc-poc-alb"
    port        = 80
    protocol    = "HTTP"
    target_type = "instance"
    health_check = {
      enabled             = true
      interval            = 30
      path                = "/"
      port                = 80
      protocol            = "HTTP"
      timeout             = 5
      unhealthy_threshold = 3
      healthy_threshold   = 2
      matcher             = "200"
    }
  }

  default_action = [{
    type = "forward"
    forward = {
      target_groups = [{
        weight = 20
      }]
      stickiness = {
        duration = 300
        enabled  = true
      }
    }
  }]

  alb_listener = {
    port     = 88
    protocol = "HTTP"
  }

  listener_rules = {
    rule1 = {
      priority = 9
      actions = [
        {
          type  = "redirect"
          order = 1
          redirect = {
            host        = "docs.example.com"
            path        = "/redirect"
            query       = "action=redirect"
            protocol    = "HTTPS"
            port        = 443
            status_code = "HTTP_301"
          }
        }
      ]
      conditions = [
        {
          host_header = {
            values = ["example.com"]
          }
        }
      ]
    },
  }

}
