#!/bin/bash

# Update system
echo "Updating system..."
apt-get update && apt-get -y dist-upgrade && apt -y autoremove

# Install dependencies
echo "Installing dependencies..."
apt install -y python3 python3-pip python3-venv nginx tor lsof

# Create a virtual environment
echo "Creating a virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python packages
echo "Installing Python packages..."
pip install Flask beautifulsoup4 requests

# Create project directory structure
echo "Creating project directory structure..."
mkdir -p data/{css,chapters}
touch data/css/style.css
touch data/chapters/toc.html
touch data/cover.html

# Configure Nginx
echo "Configuring Nginx..."
sudo rm -f /etc/nginx/sites-enabled/default
sudo bash -c 'cat > /etc/nginx/sites-available/book-project << EOL
server {
    listen 80;
    server_name localhost;
    root /data;
    index cover.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location /chapters {
        autoindex on;
    }
}
EOL'
sudo ln -sf /etc/nginx/sites-available/book-project /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Configure Tor Onion Service
echo "Configuring Tor Onion Service..."
sudo bash -c 'cat >> /etc/tor/torrc << EOL
HiddenServiceDir /var/lib/tor/book-project/
HiddenServiceVersion 3
HiddenServicePort 80 127.0.0.1:80
EOL'
sudo systemctl restart tor
sleep 10

# Display Onion address
echo "Displaying Onion address..."
sudo cat /var/lib/tor/book-project/hostname

# Instructions
echo "Installation complete! To start working on your project, activate the virtual environment by running 'source venv/bin/activate'."
python app.py
