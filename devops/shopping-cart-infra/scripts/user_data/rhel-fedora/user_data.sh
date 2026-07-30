#!/bin/bash
################################## USER DATA - RHEL/Fedora ##################################
set -exo pipefail

dnf update -y

#============== Install MySQL client ==============#
dnf install -y mariadb105
mysql --version

#============== Install AWS CLI v2 ==============#
if command -v aws &>/dev/null; then
  aws --version
else
  if ! dnf install -y aws-cli; then
    dnf install -y unzip curl
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
    unzip -q /tmp/awscliv2.zip -d /tmp
    /tmp/aws/install
    rm -rf /tmp/aws /tmp/awscliv2.zip
  fi
  aws --version
fi

#============== Install Docker ==============#
dnf install -y docker
usermod -aG docker ec2-user
systemctl start docker
systemctl enable docker
docker --version

#============== Install Docker Compose (plugin) ==============#
dnf install -y docker-compose-plugin
docker compose version

#============== Install kubectl ==============#
KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
kubectl version --client

#============== Install CodeDeploy Agent ==============#
# dnf install -y ruby wget
# wget https://aws-codedeploy-ap-southeast-1.s3.amazonaws.com/latest/install
# chmod +x ./install
# ./install auto
# systemctl start codedeploy-agent
# systemctl enable codedeploy-agent
