# Expects this variable to be set as environment variable TF_VAR_digitalocean_token or through CLI
# see https://www.terraform.io/docs/configuration/variables.html
variable "digitalocean_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
    token = "${var.digitalocean_token}"
}

resource "digitalocean_droplet" "server" {
    image = "ubuntu-16-04-x64"
    name = "rancher-server"
    region = "nyc2"
    size = "2gb"
    backups = false
    user_data = "${file("user-data-server.txt")}"
    ssh_keys = [7093539]
}

provider "rancher" {
  api_url = "http://${digitalocean_droplet.server.ipv4_address}:8080"
}

resource "rancher_environment" "default" {
  depends_on = ["digitalocean_droplet.server"]
  name = "env1"
  description = "The Default environment"
  orchestration = "cattle"
}

resource "rancher_registration_token" "default" {
  depends_on = ["digitalocean_droplet.server"]
  name = "default_token"
  description = "Registration token for the env1 environment"
  environment_id = "${rancher_environment.default.id}"
}

data "template_file" "node_user_data" {
    template = "${file("user-data-node.tpl")}"
    vars {
        rancher_registration_cmd = "${rancher_registration_token.default.command}"
    }
}

resource "digitalocean_droplet" "rancher_node" {
    count = "2"
    image = "ubuntu-16-04-x64"
    name = "rancher_node${count.index}"
    region = "nyc2"
    size = "4gb"
    backups = false
    user_data = "${data.template_file.node_user_data.rendered}"
    ssh_keys = [7093539]
}
