#!/bin/sh

# Detect the operating system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    echo "Detected OS: $OS"
else
    echo "Unsupported OS"
    exit 1
fi

if [ "$OS" = "ubuntu" ]; then
    sudo echo 'Installing Dependencies of Docker CE on Ubuntu'
    sudo apt-get update
    sudo apt-get install ca-certificates curl -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    echo 'Installing Docker CE on Ubuntu'
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

elif [ "$OS" = "amzn" ]; then
     sudo echo 'Installing Dependencies of Docker CE on Amazon Linux'
      sudo yum update -y
      sudo yum install ca-certificates curl docker -y

      echo 'Starting Docker service on Amazon Linux'
      sudo service docker start
      sudo systemctl enable docker
else
    echo "Unsupported OS"
    exit 1
fi
