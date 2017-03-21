provider "aws" {
  region     = "us-west-2"
  shared_credentials_file = "/Users/wjimenez/.aws/credentials"

}

resource "aws_instance" "server" {
  ami           = "ami-7ac6491a"
  instance_type = "m4.large"

  tags {
    Name = "William-Swarm-server"
  }
  user_data = "${file("user-data-server.txt")}"
  key_name = "william"
  vpc_security_group_ids = ["sg-eb4f278e","sg-48efe630"]
}

/*provider "rancher" {
  api_url = "http://${aws_instance.server.public_dns}:8080"
}

resource "rancher_environment" "default" {
  depends_on = ["aws_instance.server"]
  name = "env1"
  description = "The Default environment"
  orchestration = "cattle"
}

resource "rancher_registration_token" "default" {
  depends_on = ["aws_instance.server"]
  name = "default_token"
  description = "Registration token for the env1 environment"
  environment_id = "${rancher_environment.default.id}"
}

data "template_file" "node_user_data" {
    template = "${file("user-data-node.tpl")}"
    vars {
        rancher_registration_cmd = "${rancher_registration_token.default.command}"
    }
}*/

resource "aws_instance" "rancher_node" {
  count = "2"
  ami           = "ami-7ac6491a"
  instance_type = "m4.large"

  tags {
    Name = "William-Swarm-node-${count.index}"
  }
  user_data = "${file("user-data-node-non-dynamic.txt")}"
  key_name = "william"
  vpc_security_group_ids =  ["sg-eb4f278e","sg-48efe630"]

}
