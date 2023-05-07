#----------------------------------------------------------
# Provision Highly Available Webserver launched on Docker Container
#   - Zero DownTime
#   - Green/Blue Deployment
#
# Create: 
#    - Security Group for Web Server
#    - Launch Configuration with Auto AMI Lookup
#    - Auto Scaling Group using 2 Availability Zones
#    - Elastic Load Balancer in 2 Availability Zones
#    - Docker Image creating and building
#    - Docker Container launching
#
# Made by Vitali Aleksandrov 07-May-2023
#-----------------------------------------------------------

provider "aws" {
  region = var.region
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

# Creating Launch Configuration with Docker webserver userdata
resource "aws_launch_configuration" "main" {
  name_prefix     = "${var.env}-${var.lc_name}"
  image_id        = data.aws_ami.latest.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.main.id]
  user_data       = file("userdata.sh")

  metadata_options {
    http_put_response_hop_limit = 3
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Main Autoscaling Group
resource "aws_autoscaling_group" "main" {
  name                 = "ASG-${aws_launch_configuration.main.name}"
  launch_configuration = aws_launch_configuration.main.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  load_balancers       = [aws_elb.main.name]
  health_check_type    = "ELB"


  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = {
      Name  = "${var.env}-Webserver-ASG"
      Owner = "daisuke"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# Creating Main Elastic Load Balancer
resource "aws_elb" "main" {
  name               = "${var.env}-main-elb"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups    = [aws_security_group.main.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
}


# Creating Main Security Group
resource "aws_security_group" "main" {
  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      to_port     = ingress.value
      from_port   = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
