#!/bin/bash
################################## USER DATA - DEBIAN ##################################
set -exo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update

#============== Install sql client ==============#
apt-get install -y mysql-client
mysql --version

#============== Install AWS CLI v2 ==============#
# apt package awscli is not available on Ubuntu 22.04 (Jammy)
apt-get install -y unzip curl
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip
aws --version

#============== Install docker ==============#
apt-get install -y cloud-utils apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce
usermod -aG docker ubuntu
systemctl start docker
systemctl enable docker
docker --version

#============== Install docker-compose ==============#
curl -fsSL "https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

#============== Install kubectl ==============#
KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
kubectl version --client

#============== Install CodeDeploy Agent ==============#
# apt-get install -y ruby-full wget
# wget https://aws-codedeploy-ap-southeast-1.s3.amazonaws.com/latest/install
# chmod +x ./install
# ./install auto
# systemctl start codedeploy-agent
# systemctl enable codedeploy-agent
