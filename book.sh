#!/bin/bash

# Update system
echo "Updating system..."
apt-get update && apt-get -y dist-upgrade && apt -y autoremove

# Install dependencies
echo "Installing dependencies..."
apt install -y python3 python3-pip python3-venv nginx tor

# Create a virtual environment
echo "Creating a virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python packages
echo "Installing Python packages..."
pip install Flask beautifulsoup4 requests

# Create project directory structure
echo "Creating project directory structure..."
mkdir -p book_project/{css,chapters}
touch onion-press/css/style.css
touch onion-press/chapters/toc.html
touch onion-press/cover.html

# Configure Nginx
echo "Configuring Nginx..."
sudo rm /etc/nginx/sites-enabled/default
sudo bash -c 'cat > /etc/nginx/sites-available/onion-press << EOL
server {
    listen 80;
    server_name localhost;
    root /book_project;
    index cover.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location /chapters {
        autoindex on;
    }
}
EOL'
sudo ln -s /etc/nginx/sites-available/onion-press /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Configure Tor Onion Service
echo "Configuring Tor Onion Service..."
sudo bash -c 'cat >> /etc/tor/torrc << EOL
HiddenServiceDir /var/lib/tor/onion-press/
HiddenServiceVersion 3
HiddenServicePort 80 127.0.0.1:80
EOL'
sudo systemctl restart tor

# Display Onion address
echo "Displaying Onion address..."
sudo cat /var/lib/tor/onion-press/hostname

# Instructions
echo "Installation complete! To start working on your project, activate the virtual environment by running 'source venv/bin/activate'."
python app.py
