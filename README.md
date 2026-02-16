# Debian 13 (Trixie) Post-Install System & AI Stack

A comprehensive, linear bash script designed to transform a fresh Debian 13 (Trixie) installation into a fully configured workstation for development, multimedia, and local AI.

## 🚀 Overview

This script automates the tedious parts of a fresh install, handling everything from mirror optimization and security hardening to setting up a local LLM (Large Language Model) environment.

### Key Features

-   System Foundation: Resets and optimizes sources.list with official Debian mirrors and unlocks contrib, non-free, and non-free-firmware.
    
-   Security: Pre-configures UFW (Uncomplicated Firewall) with a "deny incoming" policy and enables Fail2Ban for brute-force protection.
    
-   Multimedia: Fully automates the compilation and installation of libdvdcss2 for encrypted DVD playback.
    
-   Third-Party Software: Sets up official repositories for:
    

	-   Google: Chrome and Earth Pro.
    
	-   Oracle: VirtualBox 7.2.
    
	-   GitHub: GitHub CLI (gh).
    

-   AI Stack:
    

	-   Installs Ollama natively for local AI model execution.
    
	-   Deploys Open WebUI via Docker, pre-configured to communicate with the host's Ollama service.
    

-   CLI & Productivity: Installs yt-dlp from source and configures a suite of useful .bashrc aliases.
    

## 🛠️ Usage

1.  Clone the repository:  
    ```
    git clone https://github.com/3ricvald3z/deb13-post-install.git  
    cd deb13-post-install  
      
    
2.  Make the script executable:  
    ```
    chmod +x debian-post-install.sh  
      
    
3.  Run with sudo:  
    ```
    sudo ./debian-post-install.sh  
      
    

## 📝 Included Aliases

The script appends several powerful shortcuts to your ~/.bashrc:

-   update: One-command system update.
    
-   ai: Quickly launch the llama3 model via Ollama.
    
-   ytdlp-other: Download videos with a custom, organized directory structure.
    
-   ll / la: Enhanced directory listing.
    

## ⚠️ Important Notes

-   Reboot Required: After the script finishes, a reboot is necessary to apply group permissions (Docker, Wireshark, VirtualBox).
    
-   Web Interface: Access the Open WebUI at http://localhost:3000 once the Docker container is running.
    
-   GPU Support: If you have an NVIDIA or AMD GPU, Ollama will attempt to utilize it automatically; otherwise, it defaults to CPU-only mode.
    

### 

----------

