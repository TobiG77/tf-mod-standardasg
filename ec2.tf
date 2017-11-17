resource "aws_lb_target_group" "standardasg" {
  name     = "${var.application_name}"
  port     = "${var.application_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  depends_on = ["aws_lb.standardasg"]

  health_check {
    path                = "${var.health_check_path}"
    unhealthy_threshold = 3
    port                = "${var.application_port}"
  }
}

resource "aws_lb" "standardasg" {
  name     = "${var.application_name}"
  internal        = false
  security_groups = ["${aws_security_group.lb_standardasg.id}"]
  subnets         = ["${var.public_subnets}"]

  enable_deletion_protection = false

  access_logs {
    bucket = "${aws_s3_bucket.cloudwatch-logs.bucket}"
    prefix = "lb/standardasg"
  }

  tags {
    Name = "standardasg"
  }
}

resource "aws_lb_listener" "standardasg" {
  load_balancer_arn = "${aws_lb.standardasg.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.standardasg.arn}"
    type             = "forward"
  }
}

resource "aws_security_group" "lb_standardasg" {
  name        = "lb_standardasg permit http"
  description = "lb_standardasg permit http"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "ALB:standardasg"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "cloudwatch-logs" {
  bucket = "standardasg-${var.stage}-cloudwatch-logs"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix = "/"

    tags {
      "rule"      = "log"
      "autoclean" = "true"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = 60
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = 90
    }
  }

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::standardasg-${var.stage}-cloudwatch-logs/lb/*"],
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}

data "aws_elb_service_account" "main" {}
