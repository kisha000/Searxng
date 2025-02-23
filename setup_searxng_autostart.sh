#!/bin/bash

set -e  # Exit immediately if a command fails

SERVICE_FILE="/etc/systemd/system/searxng.service"

echo "Creating systemd service file for SearXNG..."

sudo tee $SERVICE_FILE > /dev/null <<EOF
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

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Enabling SearXNG service to start on boot..."
sudo systemctl enable searxng

echo "Starting SearXNG service..."
sudo systemctl start searxng

echo "Checking service status..."
sudo systemctl status searxng --no-pager

echo "SearXNG is now set to start automatically on boot!"
