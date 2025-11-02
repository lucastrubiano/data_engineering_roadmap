# Installation guide for Docker and Docker Compose on Amazon Linux 2 EC2 instance

# Update packages
sudo yum update -y

# Install Docker
sudo yum install docker -y

# Start Docker
sudo service docker start

# Add ec2-user to the docker group
sudo usermod -a -G docker ec2-user

# Make Docker start on boot
sudo chkconfig docker on

# Install Docker Compose
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

# Apply executable permissions to the binary
sudo chmod +x /usr/local/bin/docker-compose

# Create a symbolic link to /usr/bin
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify the installation
docker --version
docker-compose --version