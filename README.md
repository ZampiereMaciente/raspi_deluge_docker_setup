# 🚀 Raspberry Pi Deluge Docker Setup

This repository contains a **Bash script** that automates the installation and configuration of:

- 🐳 **Docker** and **Docker Compose**  
- 🌐 **Deluge** torrent client (using [linuxserver/deluge](https://hub.docker.com/r/linuxserver/deluge))  
- 💾 Automatic mount of an external SSD for persistent downloads  

With just one script, your Raspberry Pi will be ready to download torrents directly to your external SSD.  

---


## 📸 My Setup Example

![raspberrypi-deluge](https://github.com/user-attachments/assets/c40c1ba4-cc45-4be2-91b6-e89f496755bb)

---

## 🛒 Materials Used

- Raspberry Pi 3 (1GB RAM)  
- microSD 32GB → for **Raspberry Pi OS Lite installation**  
- 2.5" SSD Case (USB)  
- SSD 256GB → for **torrent downloads**  
- Raspberry Pi Power Supply  
- Internet connection  

---

## 📋 Features

- ✅ Installs Docker and Docker Compose  
- ✅ Configures SSD auto-mount via `/etc/fstab`  
- ✅ Creates directories for Deluge configs and downloads  
- ✅ Deploys Deluge in a Docker container  
- ✅ Stores downloads directly on external SSD  

---

## 🔧 Installation

1. Clone this repository:  
   ```bash
   git clone https://github.com/<your-username>/<your-repo-name>.git
   cd <your-repo-name>

---

2. Make the script executable:
   ```bash
   chmod +x setup-deluge.sh

3. Run the script:
   ```bash
   ./setup-deluge.sh
   
---

## ▶️ Usage After Installation

Once the script has finished, Docker and Deluge are ready to use.
Here are the commands you’ll need most often:

1. Start the container:
   ```bash
   cd /home/pi/deluge
   docker compose up -d

2. Stop the container:
   ```bash
   docker stop deluge

3. Check logs:
   ```bash
   docker logs -f deluge

4. Update Deluge container:
   ```bash
   cd /home/pi/deluge
   docker compose pull
   docker compose up -d

---

## 🌍 Access Deluge WebUI

Open your browser and go to: http://raspberry-pi-ip:8112

Default password: `deluge`
