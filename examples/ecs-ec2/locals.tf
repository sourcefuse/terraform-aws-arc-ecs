locals {
  security_group_name = "arc-alb-sg"

  ecs_cluster = {
    name                        = "arc-ecs-ec2-poc"
    create_cluster              = true
    create_cloudwatch_log_group = true
    service_connect_defaults    = {}
    settings                    = []

    configuration = {
      execute_command_configuration = {
        logging = "OVERRIDE"
        log_configuration = {
          log_group_name = "arc-poc-cluster-log-group-ec2"
        }
      }
    }
  }

  capacity_provider = {
    autoscaling_capacity_providers = {}
    use_fargate                    = false
    fargate_capacity_providers = {
    }
  }
  ecs_service = {
    create_service = false
  }

  launch_template = {
    name = "my-launch-template"

    block_device_mappings = [
      {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 30
        }
      }
    ]

    cpu_options = {
      core_count       = 1
      threads_per_core = 1
    }

    disable_api_stop        = false
    disable_api_termination = false
    ebs_optimized           = true


    iam_instance_profile = {
      name = aws_iam_role.ec2_role.name
    }

    image_id                             = data.aws_ami.amazon_linux.id
    instance_initiated_shutdown_behavior = "terminate"
    instance_type                        = "t3.medium"
    kernel_id                            = null
    key_name                             = "my-keypair"

    monitoring = {
      enabled = true
    }

    network_interfaces = [
      {
        associate_public_ip_address = true
        ipv4_prefixes               = []
        ipv6_prefixes               = []
        ipv4_addresses              = []
        ipv6_addresses              = []
        network_interface_id        = null
        private_ip_address          = null
        subnet_id                   = data.aws_subnets.private.ids[0]
      }
    ]

    placement = {
      availability_zone = "us-east-1a"
    }


    tag_specifications = [
      {
        resource_type = "instance"
        tags = {
          Name        = "my-instance"
          Environment = "dev"
        }
      }
    ]
  }

  asg = {
    name                = "my-asg"
    min_size            = 1
    max_size            = 3
    desired_capacity    = 2
    vpc_zone_identifier = tolist(data.aws_subnets.private.ids)

    health_check_type         = "EC2"
    health_check_grace_period = 300
    protect_from_scale_in     = false
    default_cooldown          = 300

    instance_refresh = {
      strategy = "Rolling"
      preferences = {
        min_healthy_percentage = 50
      }
    }
  }


  ############################### ECS Services ################################

  ecs_services = {
    service1 = {
      ecs_cluster = {
        create_cluster = false
      }
      ecs_service = {
        cluster_name             = "arc-ecs-module-poc-1"
        service_name             = "arc-ecs-module-service-poc-1"
        repository_name          = "12345.dkr.ecr.us-east-1.amazonaws.com/arc/arc-poc-ecs"
        ecs_subnets              = data.aws_subnets.private.ids
        enable_load_balancer     = true
        aws_lb_target_group_name = "arc-poc-alb-tg"
        create_service           = true
      }

      task = {
        tasks_desired        = 1
        launch_type          = "EC2"
        network_mode         = "awsvpc"
        compatibilities      = ["EC2"]
        container_port       = 80
        container_memory     = 1024
        container_vcpu       = 256
        container_definition = "container/container_definition.json.tftpl"
      }

      lb = {
        name              = "arc-load-balancer"
        listener_port     = 80
        security_group_id = "sg-023e8f71ae18450ff"
      }
    }

    service2 = { # FIXED: Changed from duplicate "service1" to "service2"
      ecs_cluster = {
        create_cluster = false
      }
      ecs_service = {
        cluster_name             = "arc-ecs-module-poc-2"
        service_name             = "arc-ecs-module-service-poc-2"
        repository_name          = "12345.dkr.ecr.us-east-1.amazonaws.com/arc/arc-poc-ecs"
        ecs_subnets              = data.aws_subnets.private.ids
        enable_load_balancer     = true
        aws_lb_target_group_name = "arc-poc-alb-tg"
        create_service           = true
      }

      task = {
        tasks_desired        = 1
        launch_type          = "EC2"
        network_mode         = "awsvpc"
        compatibilities      = ["EC2"]
        container_port       = 80
        container_memory     = 1024
        container_vcpu       = 256
        container_definition = "container/container_definition.json.tftpl"
      }

      lb = {
        name              = "arc-load-balancer"
        listener_port     = 80
        security_group_id = "sg-023e8f71ae18450ff"
      }
    }
  }

  ############################### Load Balancer Config ################################

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
      { subnet_id = data.aws_subnets.private.ids[0] },
      { subnet_id = data.aws_subnets.private.ids[1] }
    ]

    access_logs = {
      enabled = false
      bucket  = "alb-logs"
      prefix  = "alb-logs"
    }

    connection_logs = {
      enabled = false
      bucket  = "connection-logs"
      prefix  = "connection-logs"
    }
  }

  ############################### Security Group Config ################################

  security_group_data = {
    create      = true
    description = "Security Group for alb"

    ingress_rules = [
      {
        description = "Allow VPC traffic"
        cidr_block  = "0.0.0.0/0" # Ensure it's a string
        from_port   = 443
        ip_protocol = "tcp"
        to_port     = 443
      },
      {
        description = "Allow traffic from self"
        self        = true
        from_port   = 80
        ip_protocol = "tcp"
        to_port     = 80
      }
    ]

    egress_rules = [
      {
        description = "Allow all outbound traffic"
        cidr_block  = "0.0.0.0/0" # Ensure it's a string
        from_port   = 0
        ip_protocol = "-1"
        to_port     = 0
      }
    ]
  }

  ############################### Target Group Config ################################

  target_group_config = {
    name        = "arc-poc-alb"
    port        = 80
    protocol    = "HTTP"
    target_type = "ip"

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

  ############################### Default ALB Action ################################

  default_action = [
    {
      type = "forward"
      forward = {
        target_groups = [{ weight = 20 }]
        stickiness = {
          duration = 300
          enabled  = true
        }
      }
    }
  ]

  ############################### ALB Listener ################################

  alb_listener = {
    port     = 88
    protocol = "HTTP"
  }

  ############################### Listener Rules ################################

  listener_rules = {
    rule2 = {
      priority = 999
      actions = [
        {
          type  = "fixed-response"
          order = 1
          fixed_response = {
            status_code  = "200"
            content_type = "text/plain"
            message_body = "OK"
          }
        }
      ]
      conditions = [
        {
          path_pattern = {
            values = ["/status"]
          }
        }
      ]
    }
  }
}
