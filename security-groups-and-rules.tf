resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "ssh jump host"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "EC2:ssh jump host"
  }

  ingress {
    description = "permit pings"
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.permit_ping_cidr}"]
    self        = true
  }

  ingress {
    description = "permit ssh from home"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.permit_ssh_cidr}"]
  }

  egress {
    description = "permit any outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
