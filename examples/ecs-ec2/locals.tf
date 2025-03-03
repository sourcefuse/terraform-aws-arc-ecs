locals {
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

}
