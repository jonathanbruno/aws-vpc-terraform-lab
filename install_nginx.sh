#!/bin/bash

sudo yum update -y

# Install NGINX
sudo amazon-linux-extras install nginx1 -y

# Create a simple HTML page
sudo bash -c 'cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" href="/favicon.ico" type="image/x-icon">
    <title>Welcome to NGINX</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
        }
        h1 {
            color: #3498db;
        }
        p {
            color: #2c3e50;
        }
    </style>
</head>
<body>
    <h1>Welcome to your NGINX server!</h1>
    <p>This page was automatically created by EC2 user data.</p>
</body>
</html>
EOF'

sudo systemctl start nginx
sudo systemctl enable nginx