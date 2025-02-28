#!/bin/bash

# Variables
SERVICE_NAME="searxng-git-auto-update"
TIMER_NAME="$SERVICE_NAME.timer"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
TIMER_FILE="/etc/systemd/system/$TIMER_NAME"
GIT_DIR="/usr/local/searxng/searxng-src"
LOG_FILE="/var/log/git_auto_update.log"

# Create systemd service file
echo "[Unit]
Description=Git Auto Update Service
After=network.target

[Service]
ExecStart=/usr/bin/git -C $GIT_DIR pull origin master
WorkingDirectory=$GIT_DIR
User=root
Group=root
StandardOutput=append:$LOG_FILE
StandardError=append:$LOG_FILE
Restart=always" | sudo tee $SERVICE_FILE > /dev/null

# Create systemd timer file
echo "[Unit]
Description=Runs Git Auto Update every 3 hours

[Timer]
OnBootSec=5min
OnUnitActiveSec=3h
Unit=$SERVICE_NAME.service

[Install]
WantedBy=timers.target" | sudo tee $TIMER_FILE > /dev/null

# Reload systemd, enable, and start the timer
sudo systemctl daemon-reload
sudo systemctl enable $TIMER_NAME
sudo systemctl start $TIMER_NAME

echo "Systemd service and timer created. The repository will update every 3 hours."

