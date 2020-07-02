
data "template_file" "user_data" {
    template = file("${path.root}/userdata/fluentd.tpl")
}

resource "aws_instance" "fluentd" {
    count = var.enabled ? 1 : 0
    subnet_id = var.subnet_id
    iam_instance_profile = var.instance_profile_name
    instance_type = var.instance_type
    ami = var.image_id
    key_name = var.key_pair_name
    security_groups = var.security_groups
    user_data = base64encode(data.template_file.user_data.template)
    tags = {
        Name = "fluentd_${terraform.workspace}_${var.cluster_id}"
        ClusterId = var.cluster_id
    }
    root_block_device {
        volume_type = "gp2"
        volume_size = 15
    }
}