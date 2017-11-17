resource "aws_autoscaling_group" "standardasg" {
  availability_zones        = ["${var.region}a", "${var.region}b", "${var.region}c"]
  vpc_zone_identifier       = [ "${var.private_subnets}" ]
  name                      = "${var.application_name}"
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.standardasg.name}"

  timeouts {
    delete = "15m"
  }
  tag {
    key                 = "asg:app"
    value               = "${var.application_name}"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "standardasg" {
  name_prefix = "${var.application_name}-"
  image_id    = "${var.image_id}"

  key_name = "${var.ec2_ssh_key}"

  instance_type = "${var.instance_type}"

  security_groups = [
    "${aws_security_group.standardasg.id}",
    "${var.instance_security_group}"
  ]

  user_data = "${var.instance_user_data}"
  iam_instance_profile = "${var.iam_instance_profile}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "standardasg" {
  name        = "${var.application_name} - standardasg webapp"
  description = "standardasg webapp"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "EC2:standardasg ${var.application_name}"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  ingress {
    from_port       = "${var.application_port}"
    to_port         = "${var.application_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.lb_standardasg.id}"]
  }

  egress {
    description = "permit any outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = "${aws_autoscaling_group.standardasg.id}"
  alb_target_group_arn   = "${aws_lb_target_group.standardasg.arn}"
}
