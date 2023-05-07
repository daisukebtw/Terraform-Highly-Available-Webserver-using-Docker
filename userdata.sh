#!/bin/bash

# Docker installation
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce

# Creating Docker Image
PrivateIP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
sudo cat > index.html <<EOF
<Html> 
<title>  
daisuke website 
</title>  
<h1>
This Website was launched by Docker and Terraform with $PrivateIP!
</h1>
<Body>   
</Body>  
</Html>  
EOF
sudo cat > Dockerfile <<EOF
FROM nginx
COPY index.html /usr/share/nginx/html
EOF

sudo docker build -t s3-nginx .

# Docker Container launch
sudo docker run -dp 80:80 s3-nginx

# Linux post-install
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable docker
