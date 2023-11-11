#!/bin/bash

# Function to install Docker
install_docker() {
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$(id -un)"
    sudo adduser jenkins
    sudo usermod -aG docker jenkins
    sudo systemctl start docker
    local docker_gid=$(getent group docker | cut -d: -f3)
    if [[ $? -ne 0 ]]; then
        echo "Docker install failed"
        exit 1
    else
        echo "Docker installed successfully"
    fi
    if [[ $docker_gid -eq 991 ]]; then
        echo "Docker group already has GID 991."
    else
        echo "Updating Docker group GID to 991..."
        sudo groupmod -g 991 docker
        sudo systemctl restart docker
        echo "Docker group GID updated to 991."
    fi
}

# Install Nginx
sudo yum -y install nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Install Docker (if not installed)
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    install_docker
fi

# Wait for Docker to start
sleep 10

# Set permissions on /var/run/docker.sock
sudo chown root:docker /var/run/docker.sock

# Pull Jenkins Docker image
sudo docker pull alexsimple/jenkins_jcasc:v4

# Run Jenkins container on port 8080 with elevated privileges
sudo docker run --name jenkins --rm -d -p 8080:8080 -v jenkins_data:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD='P@ssword2#J&N1ks' alexsimple/jenkins_jcasc:v4
sudo chown -R nginx:nginx /var/lib/docker/volumes/jenkins_data

# Configure Nginx as a reverse proxy for Jenkins
sudo bash -c 'cat <<EOT > /etc/nginx/conf.d/jenkins.conf
server {
    listen 80;
    server_name jenkins-io.in;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    access_log /var/log/nginx/jenkins_access.log;
    error_log /var/log/nginx/jenkins_error.log;
}
EOT'

# Reload Nginx to apply the configuration
sudo systemctl reload nginx

echo "Jenkins and Nginx installation completed. Access Jenkins at http://your_domain_or_ip:8080"
