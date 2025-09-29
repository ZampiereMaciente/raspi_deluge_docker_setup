#!/bin/bash
set -e # Stop, if any command fails.

# ======================================
# USER CONFIGURATION
# ======================================
USER_NAME="pi"              # Change this if your user is different (e.g., "gen")
PUID=1000                   # User ID (check with: id -u <user>)
PGID=1000                   # Group ID (check with: id -g <user>)
TZ="America/Sao_Paulo"      # Timezone for the container
UUID_SSD="68A8-6D88"        # <<< Replace with your SSD UUID (get it with: lsblk -f)

# ======================================
# 1. UPDATE SYSTEM & INSTALL DOCKER
# ======================================
echo "[1/5] Installing Docker and Docker Compose..."

# Update system packages to latest versions
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker using the official installation script
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Add your user to the 'docker' group so you can run Docker without sudo
sudo usermod -aG docker $USER_NAME

# Install the Docker Compose plugin (modern way to use docker compose)
sudo apt-get install -y docker-compose-plugin

echo "Docker and Docker Compose installed successfully."


# ======================================
# 2. CONFIGURE AUTOMATIC SSD MOUNT
# ======================================
echo "[2/5] Setting up automatic SSD mounting..."

# Create a mount point for the SSD if it doesn’t exist
sudo mkdir -p /mnt/ssd240gb

# Add an fstab entry if it’s not already present
# - exfat: the filesystem type
# - defaults,uid=$PUID,gid=$PGID,umask=002: ensures correct user permissions
# - 0 0: disable fsck and dump on boot (typical for external drives)
if ! grep -q "$UUID_SSD" /etc/fstab; then
  echo "UUID=$UUID_SSD /mnt/ssd240gb exfat defaults,uid=$PUID,gid=$PGID,umask=002 0 0" | sudo tee -a /etc/fstab
fi

# Mount the drive now without rebooting
sudo mount -a

echo "SSD mounted successfully and will mount automatically on boot."


# ======================================
# 3. CREATE FOLDER STRUCTURE
# ======================================
echo "[3/5] Creating configuration and download directories..."

# Create the folder for Deluge configuration
mkdir -p /home/$USER_NAME/deluge/config

# Create the download folder inside the SSD mount point
mkdir -p /mnt/ssd240gb/torrent-complete

# Ensure your user owns these folders (important for container permissions)
sudo chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/deluge
sudo chown -R $USER_NAME:$USER_NAME /mnt/ssd240gb/torrent-complete

echo "Folder structure created and permissions set."


# ======================================
# 4. CREATE docker-compose.yml FILE
# ======================================
echo "[4/5] Creating docker-compose.yml for Deluge..."

# This docker-compose file defines a single service: the Deluge container.
# - Uses the official LinuxServer Deluge image.
# - Maps the config and download directories.
# - Exposes the web interface and torrent ports.
# - Restarts automatically unless manually stopped.
cat <<EOF > /home/$USER_NAME/deluge/docker-compose.yml
version: "3.8"

services:
  deluge:
    image: linuxserver/deluge:latest
    container_name: deluge
    environment:
      - PUID=$PUID          # User ID inside container
      - PGID=$PGID          # Group ID inside container
      - TZ=$TZ              # Timezone
    volumes:
      - /home/$USER_NAME/deluge/config:/config         # Persistent config storage
      - /mnt/ssd240gb/torrent-complete:/downloads      # Where downloads are saved
    ports:
      - 8112:8112          # Web UI port
      - 6881:6881          # Torrent TCP port
      - 6881:6881/udp      # Torrent UDP port
    restart: unless-stopped # Automatically restart container unless stopped manually
EOF

echo "docker-compose.yml created successfully."


# ======================================
# 5. START DELUGE CONTAINER
# ======================================
echo "[5/5] Starting Deluge container..."

# Navigate to the folder containing the compose file
cd /home/$USER_NAME/deluge

# Launch the container in detached mode (runs in background)
docker compose up -d

echo "Deluge container is now running!"
echo "Access the Deluge Web UI from any browser:"
echo "http://<YOUR_RASPBERRY_PI_IP>:8112"
echo "(Default password: deluge)"
