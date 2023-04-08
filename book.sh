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
mkdir -p book_project/{css,chapters}
touch book_project/css/style.css
touch book_project/chapters/toc.html
touch book_project/cover.html

# Configure Nginx
echo "Configuring Nginx..."

sudo ln -sf /etc/nginx/sites-available/book-project.nginx /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx

cat > /etc/nginx/sites-available/book-project.nginx << EOL
server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

sudo ln -sf /etc/nginx/sites-available/book_project /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Configure Tor Onion Service
echo "Configuring Tor Onion Service..."
sudo bash -c 'cat >> /etc/tor/torrc << EOL
HiddenServiceDir /var/lib/tor/book_project/
HiddenServiceVersion 3
HiddenServicePort 80 127.0.0.1:5000
EOL'
sudo systemctl restart tor
sleep 10

# Display Onion address
echo "Displaying Onion address..."
sudo cat /var/lib/tor/book-project/hostname

# Instructions
echo "Installation complete! To start working on your project, activate the virtual environment by running 'source venv/bin/activate'."
python app.py
