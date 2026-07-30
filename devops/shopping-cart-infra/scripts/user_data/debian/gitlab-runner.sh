#!/bin/bash
################################## USER DATA - GITLAB RUNNER ##################################
set -exo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update

#============== Install AWS CLI v2 ==============#
apt-get install -y unzip curl gnupg
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip
aws --version

#============== Install Docker ==============#
apt-get install -y apt-transport-https ca-certificates software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce
usermod -aG docker ubuntu
systemctl start docker
systemctl enable docker
docker --version

#============== Install kubectl ==============#
KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
kubectl version --client

#============== Install GitLab Runner ==============#
curl -fsSL "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash
apt-get install -y gitlab-runner
usermod -aG docker gitlab-runner
gitlab-runner --version
systemctl start gitlab-runner
systemctl enable gitlab-runner
systemctl status gitlab-runner
