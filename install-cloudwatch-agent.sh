#!/bin/sh

CLOUDWATCH_AGENT_CONFIG_PATH="/opt/aws/amazon-cloudwatch-agent/bin/config.json"
CLOUDWATCH_AGENT_COMMON_CONFIG_PATH="/opt/aws/amazon-cloudwatch-agent/etc/common-config.toml"

# Detect the OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
	echo "Detected OS: $OS"
else
    OS=$(uname -s)
fi

sudo echo 'Installing Dependencies of Docker CE'
mkdir -p /tmp/install-cloudwatch-agent

if [ "$OS" = "ubuntu" ]; then
    wget -O /tmp/install-cloudwatch-agent/amazon-cloudwatch-agent.deb https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    sudo dpkg -i -E /tmp/install-cloudwatch-agent/amazon-cloudwatch-agent.deb
elif [ "$OS" = "amzn" ]; then
    wget -O /tmp/install-cloudwatch-agent/amazon-cloudwatch-agent.rpm https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
    sudo rpm -U /tmp/install-cloudwatch-agent/amazon-cloudwatch-agent.rpm
else
    echo "Unsupported OS: $OS"
    exit 1
fi

sudo tee "$CLOUDWATCH_AGENT_COMMON_CONFIG_PATH" > /dev/null <<EOF
[credentials]
   shared_credential_profile = "AmazonCloudWatchAgent"
EOF

sudo tee "$CLOUDWATCH_AGENT_CONFIG_PATH" > /dev/null <<EOF
{
	"agent": {
		"metrics_collection_interval": 60,
		"run_as_user": "root"
	},
	"metrics": {
                "append_dimensions":{
                        "ImageID": "\${aws:ImageId}",
                        "InstanceId":"\${aws:InstanceId}",
                        "InstanceType":"\${aws:InstanceType}"
                },
                "namespace": "Lightsail/CW",
		"metrics_collected": {
			"cpu": {
				"measurement": [
					"cpu_usage_idle"
				],
				"metrics_collection_interval": 60,
				"resources": [
					"*"
				],
				"totalcpu": true
			},
                        "mem": {
				"measurement": [
					"mem_used_percent"
				],
				"metrics_collection_interval": 60
			}
		}
	}
}
EOF

echo "Generated: $CLOUDWATCH_AGENT_CONFIG_PATH"
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
# sudo aws configure --profile AmazonCloudWatchAgent
