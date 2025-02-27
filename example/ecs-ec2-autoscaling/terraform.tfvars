environment = "dev"

ecs_cluster = {
  name = "arc-ecs-ec2-poc"
  configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        log_group_name = "arc-poc-cluster-log-group-ec2"
      }
    }
  }
  create_cloudwatch_log_group = true
  service_connect_defaults    = {}
  settings                    = []
}

capacity_provider = {
  autoscaling_capacity_providers = {}
  use_fargate                    = false
  fargate_capacity_providers     = {}
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
    name = "poc-iam-role"
  }

  image_id                             = "ami-1234567890"
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
      subnet_id                   = "subnet-1234567890"
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
  vpc_zone_identifier = ["subnet-1234567890", "subnet-1234567890"]

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
  launch_type          = "EC2"
  network_mode         = "awsvpc"
  compatibilities      = ["EC2"]
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
