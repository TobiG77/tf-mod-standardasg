# variable that are deliberately kept empty to force conscious context switches

# variable "stage" {
#   description = "The stack stage, i.e. [ dev, prod ]"
# }

variable "region" {}
variable "stage" {}

variable "ec2_ssh_key" {
  description = "The key stored in ec2 to associate with started instance for remote login."
}

variable "vpc_id" {}
variable "permit_ping_cidr" {}
variable "permit_ssh_cidr" {}

variable "private_subnets" {
  type = "list"
}
variable "public_subnets" {
  type = "list"
}

variable "health_check_path" {}
variable "application_port" {}

variable "image_id" {}
variable "instance_type" {}

variable "iam_instance_profile" {
  description = "The instance profile, that will be attached to instances starting in the ASG"
}

variable "instance_user_data" {}
variable "instance_security_group" {}
variable "application_name" {}