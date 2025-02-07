#!/bin/sh
sudo echo 'Installing AWS CLI'
sudo apt update
sudo apt install -y unzip
mkdir -p ~/install-aws-cli
sudo echo "Download AWS CLI Package"
wget -O ~/install-aws-cli/awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
OLDPWD=$(pwd)
cd ~/install-aws-cli && unzip awscliv2.zip && sudo ./aws/install && cd "$OLDPWD"
