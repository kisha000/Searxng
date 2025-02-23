#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

echo "Updating system and installing required packages..."
sudo apt-get update
sudo -H apt-get install -y \
    python3-dev python3-babel python3-venv \
    uwsgi uwsgi-plugin-python3 \
    git build-essential libxslt-dev zlib1g-dev libffi-dev libssl-dev

echo "Creating SearXNG system user..."
sudo -H useradd --shell /bin/bash --system \
    --home-dir "/usr/local/searxng" \
    --comment 'Privacy-respecting metasearch engine' \
    searxng

sudo -H mkdir -p "/usr/local/searxng"
sudo -H chown -R "searxng:searxng" "/usr/local/searxng"

echo "Cloning SearXNG repository..."
sudo -H -u searxng -i bash << EOF
git clone "https://github.com/searxng/searxng" "/usr/local/searxng/searxng-src"
EOF

echo "Creating Python virtual environment..."
sudo -H -u searxng -i bash << EOF
python3 -m venv "/usr/local/searxng/searx-pyenv"
echo ". /usr/local/searxng/searx-pyenv/bin/activate" >> "/usr/local/searxng/.profile"
EOF

echo "Installing SearXNG dependencies..."
sudo -H -u searxng -i bash << EOF
command -v python && python --version
pip install -U pip setuptools wheel pyyaml
cd "/usr/local/searxng/searxng-src"
pip install --use-pep517 --no-build-isolation -e .
EOF

echo "Downloading custom settings.yml from GitHub..."
sudo -H mkdir -p "/etc/searxng"
sudo -H wget -O "/etc/searxng/settings.yml" "https://raw.githubusercontent.com/kisha000/Searxng/main/settings.yml"

echo "Enabling debug mode for testing..."
sudo -H sed -i -e "s/debug : False/debug : True/g" "/etc/searxng/settings.yml"

echo "Starting SearXNG web application..."
sudo -H -u searxng -i bash << EOF
cd /usr/local/searxng/searxng-src
export SEARXNG_SETTINGS_PATH="/etc/searxng/settings.yml"
python searx/webapp.py
EOF

echo "Disabling debug mode..."
sudo -H sed -i -e "s/debug : True/debug : False/g" "/etc/searxng/settings.yml"

echo "SearXNG installation and setup complete!"
