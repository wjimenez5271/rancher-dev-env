#!/usr/bin/env bash
# Set Hostname
uuid="$(cat /sys/class/net/*/address | head -n 1 |sed -r 's/[:]+/-/g')"
node_hostname=rancher-node-$uuid
echo "HOSTNAME=$node_hostname" >> /etc/sysconfig/network
echo "127.0.0.1  $node_hostname" >> /etc/hosts
hostname $node_hostname
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum makecache fast
yum -y install docker-ce.x86_64
sudo systemctl start docker

echo "attempting to run: "
echo "${rancher_registration_cmd}"
${rancher_registration_cmd}
