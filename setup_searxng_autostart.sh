#!/bin/bash

set -e  # Exit on error

# File paths for systemd service files
SEARXNG_SERVICE_FILE="/etc/systemd/system/searxng.service"
NGROK_SERVICE_FILE="/etc/systemd/system/ngrok.service"

echo "Setting up SearXNG as a systemd service..."

# Create systemd service for SearXNG
sudo tee $SEARXNG_SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=SearXNG - Privacy-respecting metasearch engine
After=network.target

[Service]
Type=simple
User=searxng
WorkingDirectory=/usr/local/searxng/searxng-src
ExecStart=/usr/local/searxng/searx-pyenv/bin/python searx/webapp.py
Environment="SEARXNG_SETTINGS_PATH=/etc/searxng/settings.yml"
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "Setting up ngrok as a systemd service..."

# Create systemd service for ngrok
sudo tee $NGROK_SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=ngrok tunnel for SearXNG
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/ngrok http --domain=sacred-constantly-frog.ngrok-free.app 8888
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Enabling SearXNG and ngrok to start on boot..."
sudo systemctl enable searxng
sudo systemctl enable ngrok

echo "Starting SearXNG and ngrok services..."
sudo systemctl start searxng
sudo systemctl start ngrok

echo "Checking service statuses..."
sudo systemctl status searxng --no-pager
sudo systemctl status ngrok --no-pager

echo "SearXNG and ngrok are now set to start automatically on boot!"
