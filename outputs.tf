output "lb_dns_name" {
  value = "${aws_lb.standardasg.dns_name}"
}

output "lb_target_group_arn" {
  value = "${aws_lb_target_group.standardasg.arn}"
}
