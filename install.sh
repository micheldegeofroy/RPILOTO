#!/bin/bash
# ###########################################
# ###########################################
#
# BTCLOTO BITCOIN MINER ON RPI 4
# by Michel de Geofroy
# 
# This script is intended as a basic set up 
# & should be run on a clean install of
# Raspberry Pi OS Lite (64-bit) Debian Bullseye
# Using Raspberry Pi Imager for use on a RPI 4
#
# ###########################################
# ###########################################
#
#ssh into your pi
#ssh pi@YOURDEVICEIP 
#
#If you get the below msg
#
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
#Someone could be eavesdropping on you right now (man-in-the-middle attack)!
#It is also possible that a host key has just been changed.
#The fingerprint for the ECDSA key sent by the remote host is
#
#Use this below command and ssh again
#
#ssh-keygen -R YOURDEVICEIP
#
#nano install.sh
#
#copy this code in file save and close (ctrl X , y , return)
#
# ###############################
# Set root password
# ###############################
#
#Then create a root password
#sudo passwd root
#
# ###############################
# This needs to be run as root !
# ###############################
#
#su
#
# ###############################
# Execute basic install
# ###############################
#
#bash install.sh
#
# ###############################
# Remove Cronjob & setup.sh #3
# ###############################

crontab -u pi -r
sudo rm setup.sh

# ###############################
# Update the software sources #4
# ###############################

sudo apt update -y
sudo apt upgrade -y

# ###############################
# Web Interface #5
# ###############################

sudo apt install php7.4 -y

#sudo apt purge apache2 -y
sudo apt purge php7.4 libapache2-mod-php7.4 -y
sudo apt purge -y
sudo apt autoremove -y
sudo apt clean -y
sudo apt autoclean -y
sudo apt install apache2 -y
sudo apt install libapache2-mod-php7.4 -y
sudo apt install php7.4 -y
sudo apt autoremove -y

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/index.php" -P /var/www/html/

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/miner.php" -P /var/www/html/

# ###############################
# Install Tailscale #6
# ###############################

sudo apt install apt-transport-https

curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

sudo apt update -y
sudo apt install tailscale -y

# ###############################
# Disable Swap #7
# ###############################

sudo swapoff --all
sudo apt remove dphys-swapfile -y

# ###############################
# Install glances #8
# ###############################

#sudo snap install core
#sudo snap install glances
#sudo apt install python3-pip -y
#sudo pip install glances

# ###############################
# Install Speed Test #9
# ###############################

sudo wget -O /usr/local/bin/speedtest-cli "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/speedtest.py"

chmod a+x /usr/local/bin/speedtest-cli

# ###############################
# Install watchdog #10
# ###############################

sudo echo "#Watchdog On" | sudo tee -a /boot/config.txt
sudo echo "dtparam=watchdog=on" | sudo tee -a /boot/config.txt

sudo apt install watchdog -y

sudo echo "watchdog-device = /dev/watchdog" | sudo tee -a /etc/watchdog.conf
sudo echo "watchdog-timeout = 15" | sudo tee -a /etc/watchdog.conf
sudo echo "max-load-1 = 24" | sudo tee -a /etc/watchdog.conf

sudo systemctl enable watchdog
sudo systemctl start watchdog
#sudo systemctl status watchdog

# ###############################
# Stop IPV6 #11
# ###############################

echo net.ipv6.conf.all.disable_ipv6=1 | sudo tee /etc/sysctl.d/disable-ipv6.conf
sysctl --system
sudo sed -i -e 's/$/ipv6.disable=1/' /boot/cmdline.txt

# ###############################
# Disable BT #12
# ###############################

sudo echo "# Disable Bluetooth" | sudo tee -a /boot/config.txt
sudo echo "dtoverlay=disable-bt" | sudo tee -a /boot/config.txt

sudo systemctl disable hciuart.service 
sudo systemctl disable bluetooth.service

# ###############################
# Install macchanger #13
# ###############################

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/mymacchanger.py"

#sudo crontab -u pi -l; echo "@reboot && /usr/bin/python3 /home/pi/mymacchanger.py >/dev/null 2>&1" | crontab -

sudo crontab -u pi -l > file; echo '@reboot && /usr/bin/python3 /home/pi/mymacchanger.py >/dev/null 2>&1' >> file; crontab file

# ###############################
# Install telegram bot #14
# ###############################
                                                                                                                                                             
sudo apt install python3 -y
sudo apt install jq -y
sudo apt install python3-pip -y
sudo pip install telepot

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/script.py"

sudo python3 script.py

sudo rm script.py

sudo mkdir /home/pi/Bots/

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/Bot.py" -P /home/pi/Bots/

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/bot.service" -P /etc/systemd/system/

sudo pip3 install --upgrade RPi.GPIO

sudo systemctl enable bot.service
sudo systemctl start bot.service

# ###############################
# Heartbeat Telegram #15
# ###############################

#crontab -u pi -l; echo '30 8 * * * curl -s -X POST https://api.telegram.org/bot5564114282:AAGSjjJkjNH7RB-4dUH-aJW1pMmquFEq-m8/sendMessage -d chat_id=90423887 -d text="BTC Loto is Alive !"' | crontab -

sudo crontab -u pi -l > file; echo '30 8 * * * curl -s -X POST https://api.telegram.org/bot5564114282:AAGSjjJkjNH7RB-4dUH-aJW1pMmquFEq-m8/sendMessage -d chat_id=90423887 -d text="BTC Loto is Alive !"' >> file; crontab file

# ###############################
# SSH Custom Login Splash Screen #16
# ###############################

sudo rm /etc/motd

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/motd" -P /etc/

# ###############################
# SSH Welcome Interface #17
# ###############################

mkdir -p /etc/update-motd.d/

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/ssh-welcome" -P /etc/update-motd.d/

sudo chmod +x /etc/update-motd.d/ssh-welcome
#sudo run-parts --lsbsysinit /etc/update-motd.d

# ###############################
# Uninstall Script #18
# ###############################

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/uninstall.sh"

# ###############################
# Final Reboot & Clean Up #19
# ###############################

sudo apt purge -y
sudo apt autoremove -y
sudo apt clean -y
sudo apt autoclean -y
sudo rm install.sh
sudo rm file
sudo reboot


