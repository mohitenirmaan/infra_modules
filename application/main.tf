  # ============security group======================= #

  resource "aws_security_group" "security_grp" {
    count = length(var.security_groups)

    name        = var.security_groups[count.index].name
    description = var.security_groups[count.index].description
    vpc_id      = var.vpc_id

    dynamic "ingress" {
    for_each = var.security_groups[count.index].ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_block          # [var.security_groups[count.index].sg_cidr_blocks[ingress.key]]
    }
  }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = var.egress-cidr_blocks
  } 
    tags = merge(var.tags,)
  }
# ============Elastic file Storage=================#
  resource "aws_efs_file_system" "en-efs" {
    creation_token = var.creation_token # "EFS for My Application"
  }
  resource "aws_efs_mount_target" "efs_mount_target" {
    for_each          = toset([var.private_subnet_ids])
    file_system_id = aws_efs_file_system.en-efs.id
    subnet_id      = each.value

    # Security group allowing access from instances
    security_groups = [aws_security_group.security_grp[2].id]
  }

# ============Launch Template======================= #

  resource "aws_launch_template" "API-template" {
    count = length(var.template_name)
    name  = var.template_name[count.index]
    image_id               = var.image_ids[count.index]
    instance_type          = var.instance_types[count.index]
    key_name               = var.key_names[count.index]
    vpc_security_group_ids = [aws_security_group.security_grp[count.index + 2].id]
      
    block_device_mappings {
      device_name = var.block_device_name[count.index]
      ebs {
        volume_size           = var.volume_size[count.index]
        delete_on_termination = true
      }
    }
    user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y amazon-efs-utils
              sudo apt-get install -y nfs-common
              mkdir -p /mnt/efs
              sudo mount -t efs -o tls ${aws_efs_file_system.en-efs.id}:/ /mnt/efs
              echo "${aws_efs_file_system.en-efs.id}:/ /mnt/efs efs defaults,_netdev 0 0" >> /etc/fstab
              EOF
    tags = merge(var.tags,)
  }

#=======================ASG======================
  resource "aws_autoscaling_group" "API-asg" {
    count = length(var.asg_name)

    launch_template {
      id      = aws_launch_template.API-template[count.index].id
      version = "$Latest"
    }
    name                      = var.asg_name[count.index] # Each ASG will have a different name
    max_size                  = var.max_instance
    min_size                  = var.min_instance
    desired_capacity          = var.desired_capacity
    health_check_grace_period = var.health_check_grace_period
    health_check_type         = var.health_check_type
    force_delete              = true
    vpc_zone_identifier       = slice(var.private_subnet_ids, 0, 2) # var.private_subnet_ids
    target_group_arns         = [aws_lb_target_group.target_groups[count.index].arn]  # Assigning the target group ARN

    tag {
      key                 = "Name"
      value               = var.asg_name[count.index]
      propagate_at_launch = true
    }
  }

#===================Target Scalng Policy=================
  resource "aws_autoscaling_policy" "cpu-policy" {
    count                     = length(aws_autoscaling_group.API-asg[*].id)
    name                      = aws_autoscaling_group.API-asg[count.index].id
    policy_type               = var.dynamic_policy
    estimated_instance_warmup = var.estimated_instance_warmup

    # Specify your Auto Scaling Group name
    autoscaling_group_name = aws_autoscaling_group.API-asg[count.index].id

    target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = var.predefined_metric_type
      }
      target_value = var.target_value # Adjust the target value as needed
    }
    cooldown = 600
    lifecycle {
      create_before_destroy = true
    }

  }

#=================Load balancer===================#

  resource "aws_lb_target_group" "target_groups" {
    count       = length(var.target_group_name)
    name        = var.target_group_name[count.index]
    target_type = var.target_type
    port        = var.target_port
    protocol    = var.target_protocol
    vpc_id      = var.vpc_id
  
    health_check {
    path                = var.health_check[count.index].path
    interval            = var.health_check[count.index].interval
    protocol            = var.health_check[count.index].protocol
    matcher             = var.health_check[count.index].matcher
    timeout             = var.health_check[count.index].timeout
    unhealthy_threshold = var.health_check[count.index].unhealthy_threshold
    healthy_threshold   = var.health_check[count.index].healthy_threshold
    }
    tags = merge(var.tags)
  }

  # resource "aws_acm_certificate" "my_certificate" {
  #   count = length(var.domain)
  #   domain_name       = var.domain[count.index]
  #   validation_method = "DNS"

  #   tags = {
  #     Name = "MyCertificate"
  #   }
  # }

   resource "aws_lb" "pub_alb" {
      name               = var.Alb_name  
      internal           = var.internal
      load_balancer_type = var.Alb_type
      security_groups    = [aws_security_group.security_grp[1].id]
      subnets            = var.public_subnet_ids
      enable_deletion_protection = var.enable_deletion_protection
      # access_logs {
      #   bucket  = aws_s3_bucket.lb_logs.id
      #   prefix  = "test-lb"
      #   enabled = true
      # }
      tags = merge(var.tags,)
    }
 
   resource "aws_lb_listener" "https_listener" {
     load_balancer_arn = aws_lb.pub_alb.id
     port              = var.listener_port
     protocol          = var.listener_protocol
     ssl_policy        = var.ssl_policy  # "ELBSecurityPolicy-2016-08"
     certificate_arn   = var.certificate_arn 

     default_action {
       type             = "forward"
       target_group_arn = aws_lb_target_group.target_groups[0].arn
     }
   }

  resource "aws_lb_listener_rule" "domain_based_rules" {
    count       = length(var.listener_rules)
    listener_arn = aws_lb_listener.https_listener.arn

    action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.target_groups[count.index].arn
    }
      condition {
      host_header {
        values = [var.listener_rules[count.index].domain] # Specify your second domain
      }
    }
  #   condition {
  #     path_pattern {
  #       values = [var.listener_rules[count.index].path]
  #     }
  #   }
  }

  resource "aws_instance" "server" {
    instance_type               = lookup(var.static, "itype")
    subnet_id                   = var.public_subnet_ids[0]
    ami                         = lookup(var.static, "ami")
    associate_public_ip_address = lookup(var.static, "publicip")
    key_name                    = lookup(var.static, "keyname")
    vpc_security_group_ids      = [aws_security_group.security_grp[0].id]
    
    tags = merge(
    {
      "Name" = format("%s-Bastion-host", var.name)
    },
    var.tags, )
  }
 
