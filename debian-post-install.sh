#!/bin/bash
# -----------------------------------------------------------------------------
# Debian 13 Post-Install
# -----------------------------------------------------------------------------

set -e

# 1. KILL ALL LOCKS (Fixes the "Could not get lock" error)
sudo systemctl stop packagekit || true
sudo killall -9 packagekitd || true
sudo rm -f /var/lib/apt/lists/lock
sudo rm -f /var/lib/dpkg/lock-frontend

# 2. HARD-RESET SOURCES
sudo tee /etc/apt/sources.list << EOF
deb http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware
EOF

sudo apt update
sudo apt install -y curl wget gpg ufw fail2ban docker.io

# 3. EXTERNAL REPOS (GOOGLE, VIRTUALBOX, GITHUB)
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor --yes -o /usr/share/keyrings/google.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google.list

curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes -o /usr/share/keyrings/oracle-vbox.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/oracle-vbox.gpg] https://download.virtualbox.org/virtualbox/debian trixie contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list

sudo apt update

# 4. INSTALL APPS (Direct Download for Google Earth to avoid repo misses)
wget -q https://dl.google.com/linux/direct/google-earth-pro-stable_current_amd64.deb
sudo apt install -y ./google-earth-pro-stable_current_amd64.deb
rm google-earth-pro-stable_current_amd64.deb

sudo apt install -y google-chrome-stable virtualbox-7.2 gh nmap btop git \
    python3-venv python3-pip pipx mpv vlc gimp inkscape audacity flowblade \
    keepassxc thunderbird msmtp rsync wireshark

# 5. SECURITY & DVD
sudo ufw default deny incoming && sudo ufw default allow outgoing
sudo ufw allow ssh && sudo ufw --force enable
sudo systemctl enable --now fail2ban

echo libdvd-pkg libdvd-pkg/first-install note | sudo debconf-set-selections
sudo apt install -y libdvd-pkg
sudo dpkg-reconfigure -f noninteractive libdvd-pkg

# 6. AI TOOLS (OLLAMA & OPEN WEBUI)
curl -fsSL https://ollama.com/install.sh | sh
sudo docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway \
    -v open-webui:/app/backend/data --name open-webui --restart always \
    ghcr.io/open-webui/open-webui:main

# 7. YT-DLP BINARY & CONFIG
sudo curl -L "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp" -o "/usr/local/bin/yt-dlp"
sudo chmod +x "/usr/local/bin/yt-dlp"

mkdir -p ~/.config/yt-dlp
cat > ~/.config/yt-dlp/config << EOF
-f bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best
-o "~/Downloads/YouTube/%(uploader)s/%(playlist_title|'Misc Videos')s/%(upload_date)s - %(title)s [%(id)s].%(ext)s"
EOF

# Create custom organizational directories
echo "Create custom organizational directories..."
mkdir -p /home/$SUDO_USER/Downloads/Videos /home/$SUDO_USER/Downloads/YouTube
chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/Downloads/Videos /home/$SUDO_USER/Downloads/YouTube

# 8. THE ALIASES
cat << EOF >> ~/.bashrc

# --- Added by Post-Install Script ---
alias ls='ls -F --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias update='sudo apt update && sudo apt upgrade -y'
alias ai='ollama run llama3'
alias sshkey='ssh-keygen -t ed25519 -C "\$(whoami)@\$(hostname)"'
alias ytdlp-other='yt-dlp --no-config -o "~/Downloads/Videos/%(extractor_key)s/%(uploader|Unknown Uploader)s/%(title)s [%(id)s].%(ext)s"'

if [ -z "\$VISUAL" ] && [ -z "\$EDITOR" ]; then export EDITOR=nano; fi
# --- End Post-Install Aliases ---
EOF

# 9. FINAL PERMISSIONS
sudo usermod -aG docker,wireshark,vboxusers $USER
echo "Done. All aliases (including ytdlp-other) are now in your .bashrc."
