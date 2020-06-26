variable "my_ip_cidr" {
  default = "70.106.229.141/32"
}
variable "key_pair_name" {
  default = "ecs-key-pair-us-east-1"
}
variable "zookeeper_image_id" {
  default = "ami-039a49e70ea773ffc"
}
variable "mesos_image_id" {
  default = "ami-039a49e70ea773ffc"
}
variable "zookeeper_instance_type" {
  default = "t3.micro"
}
variable "mesos_instance_type" {
  default = "t3.micro"
}
variable "environment" {
  default = "development"
}
variable "splunk_image_id" {
  default = "ami-039a49e70ea773ffc"
}
variable "splunk_instance_type" {
  default = "t3.medium"
}
variable "enable_splunk" {
  type = bool
  default = true
}