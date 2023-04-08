#!/bin/bash

# Update the system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y python3 python3-pip python3-venv tor nginx

# Create a virtual environment for Python
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

# Install Python packages
pip install requests beautifulsoup4

# Create the necessary directories
mkdir -p root/css root/chapters

# Create a basic CSS file
cat > root/css/style.css << EOL
body {
  font-family: Arial, sans-serif;
  font-size: 16px;
  line-height: 1.5;
}
EOL

# Tor onion service configuration
sudo cat >> /etc/tor/torrc << EOL
RunAsDaemon 1
HiddenServiceDir /var/lib/tor/myonionservice/
HiddenServicePort 80 127.0.0.1:8080
EOL

sudo systemctl restart tor
sleep 10

sudo ln -sf /etc/nginx/sites-available/myonionservice.nginx /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx

# Set up Nginx and Tor onion service

# Nginx configuration
sudo cat > /etc/nginx/sites-available/myonionservice.nginx << EOL
server {
    listen 80;
    server_name localhost;
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }
    
        add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
        add_header X-Frame-Options DENY;
        add_header Onion-Location http://$ONION_ADDRESS\$request_uri;
        add_header X-Content-Type-Options nosniff;
        add_header Content-Security-Policy "default-src 'self'; frame-ancestors 'none'";
        add_header Permissions-Policy "geolocation=(), midi=(), notifications=(), push=(), sync-xhr=(), microphone=(), camera=(), magnetometer=(), gyroscope=(), speaker=(), vibrate=(), fullscreen=(), payment=(), interest-cohort=()";
        add_header Referrer-Policy "no-referrer";
        add_header X-XSS-Protection "1; mode=block";
}
EOL

sudo ln -s /etc/nginx/sites-available/myonionservice /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Display the onion service address
sudo cat /var/lib/tor/myonionservice/hostname
