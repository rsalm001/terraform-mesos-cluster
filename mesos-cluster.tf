provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "aws_vpc" "default_vpc" {
  tags = { "Default" = "true" }
}

data "aws_subnet" "subnet_us_east_1d" {
  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.default_vpc.id}"] # insert value here
  }
  filter {
    name = "availability-zone"
    values = ["us-east-1d"]
  }
}

# Unique id to reference all other resouces under this template (useful for tags)
resource "random_id" "cluster_id" {
  byte_length = 8
}

# ------------------------------------------------------------------------------------
# Mesos security group shared across all components for ease
# ------------------------------------------------------------------------------------
resource "aws_security_group" "mesos_security_group" {
  name        = "mesos_security_group"
  description = "Mesos shared security group"
  vpc_id      = data.aws_vpc.default_vpc.id

  tags = {
    Name = "mesos-shared-security-group"
  }
}

resource "aws_security_group_rule" "all_egress" {
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = -1
  security_group_id = "${aws_security_group.mesos_security_group.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "mesos_security_group_self_to" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = -1
  security_group_id        = "${aws_security_group.mesos_security_group.id}"
  source_security_group_id = "${aws_security_group.mesos_security_group.id}"
}
resource "aws_security_group_rule" "home_router_cidr" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = "${aws_security_group.mesos_security_group.id}"
  cidr_blocks       = [var.my_ip_cidr]
}

# ------------------------------------------------------------------------------------
# Instance profile used across all Mesos components
# ------------------------------------------------------------------------------------

resource "aws_iam_role" "mesos_ec2_role" {
  name = "mesos_ec2_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            },
            "Action": [
                "sts:AssumeRole"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_full_attachment" {
  role       = "${aws_iam_role.mesos_ec2_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "ec2_full_attachment" {
  role       = "${aws_iam_role.mesos_ec2_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_instance_profile" "mesos_ec2_instance_profile" {
  name = "mesos_ec2_instance_profile"
  role = "${aws_iam_role.mesos_ec2_role.name}"
}


# ------------------------------------------------------------------------------------
# Zookeeper instance (standalone for now)
# ------------------------------------------------------------------------------------

module "zookeeper" {
    source = "./modules/zookeeper"

    instance_type = var.zookeeper_instance_type
    image_id = var.zookeeper_image_id
    key_pair_name = var.key_pair_name
    cluster_id = "${random_id.cluster_id.b64_std}"
    subnet_id = data.aws_subnet.subnet_us_east_1d.id
    instance_profile_name = aws_iam_instance_profile.mesos_ec2_instance_profile.name
    security_groups = ["${aws_security_group.mesos_security_group.id}"]
    environment = var.environment
}

# ------------------------------------------------------------------------------------
# Mesos Master(s)
# ------------------------------------------------------------------------------------


module "mesos-master" {
    source = "./modules/mesos"

    mesos_type = "Master"
    mesos_image_id = var.mesos_image_id
    key_pair_name = var.key_pair_name
    instance_profile_name = aws_iam_instance_profile.mesos_ec2_instance_profile.name
    security_groups = ["${aws_security_group.mesos_security_group.id}"]
    instance_type = var.mesos_instance_type
    cluster_id = "${random_id.cluster_id.b64_std}"
    asg_min_size = 1
    asg_max_size = 1
    asg_desired_capacity = 1
    environment = var.environment
}

# ------------------------------------------------------------------------------------
# Mesos Agent(s)
# ------------------------------------------------------------------------------------

module "mesos-agent" {
    source = "./modules/mesos"

    mesos_type = "Agent"
    mesos_image_id = var.mesos_image_id
    key_pair_name = var.key_pair_name
    instance_profile_name = aws_iam_instance_profile.mesos_ec2_instance_profile.name
    security_groups = ["${aws_security_group.mesos_security_group.id}"]
    instance_type = var.mesos_instance_type
    cluster_id = "${random_id.cluster_id.b64_std}"
    asg_min_size = 1
    asg_max_size = 4
    asg_desired_capacity = 3
    environment = var.environment
}

# ------------------------------------------------------------------------------------
# Mesos Marathon Framework(s)
# ------------------------------------------------------------------------------------

module "mesos-marathon" {
    source = "./modules/mesos"

    mesos_type = "Marathon"
    mesos_image_id = var.mesos_image_id
    key_pair_name = var.key_pair_name
    instance_profile_name = aws_iam_instance_profile.mesos_ec2_instance_profile.name
    security_groups = ["${aws_security_group.mesos_security_group.id}"]
    instance_type = var.mesos_instance_type
    cluster_id = "${random_id.cluster_id.b64_std}"
    asg_min_size = 1
    asg_max_size = 1
    asg_desired_capacity = 1
    environment = var.environment
}