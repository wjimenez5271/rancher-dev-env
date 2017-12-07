provider "aws" {
  region     = "us-west-2"
  shared_credentials_file = "/Users/wjimenez/.aws/credentials"

}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

resource "random_id" "server" {
  byte_length = 8
}

variable "docker_cmd" {
  default = "sudo docker run -d --restart=unless-stopped -p 8080:8080 rancher/server:stable"
}

data "template_file" "user_data" {
    template = "${file("${path.module}/user-data.tpl")}"
    vars {
        hostname-prefix = "${random_id.server.hex}"
        docker_cmd = "${var.docker_cmd}"
    }
}

resource "aws_instance" "server" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "m4.large"

  tags {
    Name = "rancher-server-${random_id.server.hex}"
  }
  user_data = "${data.template_file.user_data.rendered}"
  key_name = "william"
  vpc_security_group_ids = ["sg-eb4f278e","sg-48efe630"]
}
