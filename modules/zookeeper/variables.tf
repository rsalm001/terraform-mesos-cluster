variable "instance_type" { type = string }
variable "image_id" { type = string }
variable "key_pair_name" { type = string }
variable "cluster_id" { type = string }
variable "subnet_id" { type = string }
variable "instance_profile_name" { type = string }
variable "security_groups" { type = list(string) }
variable "environment" { type = string }