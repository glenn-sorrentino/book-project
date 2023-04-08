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
touch book_project/css/style.css
touch book_project/chapters/toc.html
touch book_project/cover.html

# Configure Nginx
echo "Configuring Nginx..."
sudo rm /etc/nginx/sites-enabled/default
sudo bash -c 'cat > /etc/nginx/sites-available/book_project << EOL
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
sudo ln -s /etc/nginx/sites-available/book_project /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Configure Tor Onion Service
echo "Configuring Tor Onion Service..."
sudo bash -c 'cat >> /etc/tor/torrc << EOL
HiddenServiceDir /var/lib/tor/book_project/
HiddenServiceVersion 3
HiddenServicePort 80 127.0.0.1:80
EOL'
sudo systemctl restart tor

# Display Onion address
echo "Displaying Onion address..."
sudo cat /var/lib/tor/book_project/hostname

# Instructions
echo "Installation complete! To start working on your project, activate the virtual environment by running 'source venv/bin/activate'."
python app.py
