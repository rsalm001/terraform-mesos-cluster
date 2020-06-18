variable "my_ip_cidr" {
  default = "173.67.202.129/32"
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