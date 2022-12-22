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
# Update the software sources
# ###############################

crontab -u pi -r

apt update -y
apt upgrade -y

# ###############################
# Fix Language Local
# ###############################

rm /etc/environment
touch /etc/environment

echo "LANGUAGE=en_US" >> /etc/environment
echo "LC_ALL=en_US" >> /etc/environment
echo "LANG=en_US" >> /etc/environment
echo "LC_TYPE=en_US" >> /etc/environment

rm /etc/default/locale
touch /etc/default/locale

echo "LANG=en_US.UTF-8" >> /etc/default/locale
echo "LC_CTYPE=en_US.UTF-8" >> /etc/default/locale
echo "LC_MESSAGES=en_US.UTF-8" >> /etc/default/locale
echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale

localedef -f UTF-8 -i en_US en_US.UTF-8 

sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/en_GB.UTF-8 UTF-8/# en_GB.UTF-8 UTF-8/g' /etc/locale.gen 

# ###############################
# Web Interface
# ###############################

apt install php7.4 -y

sudo apt-get purge apache2 -y
sudo apt-get purge php7.4 libapache2-mod-php7.4 -y
sudo apt-get purge autoremove -y
sudo apt-get install apache2 libapache2-mod-php7.4 php7.4 -y

wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/index.php -P /var/www/html/
wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/miner.php -P /var/www/html/

# ###############################
# Install Tailscale
# ###############################

apt install apt-transport-https

curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

apt update -y
apt install tailscale -y

# ###############################
# Disable Swap
# ###############################

swapoff --all
apt remove dphys-swapfile -y

# ###############################
# Install glances
# ###############################

apt install python3-pip -y
pip install glances

# ###############################
# Install Speed Test
# ###############################

wget -O /usr/local/bin/speedtest-cli https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/speedtest.py
chmod a+x /usr/local/bin/speedtest-cli

# ###############################
# Install watchdog
# ###############################

echo '#Watchdog On' >> /boot/config.txt
echo 'dtparam=watchdog=on' >> /boot/config.txt

apt install watchdog -y

echo 'watchdog-device = /dev/watchdog' >> /etc/watchdog.conf
echo 'watchdog-timeout = 15' >> /etc/watchdog.conf
echo 'max-load-1 = 24' >> /etc/watchdog.conf

systemctl enable watchdog
systemctl start watchdog
systemctl status watchdog

# ###############################
# Stop IPV6
# ###############################

echo net.ipv6.conf.all.disable_ipv6=1 | sudo tee /etc/sysctl.d/disable-ipv6.conf
sysctl --system
sed -i -e 's/$/ipv6.disable=1/' /boot/cmdline.txt

# ###############################
# Disable BT
# ###############################

echo '# Disable Bluetooth' >> /boot/config.txt
echo 'dtoverlay=disable-bt' >> /boot/config.txt

systemctl disable hciuart.service 
systemctl disable bluetooth.service

# ###############################
# Install macchanger
# ###############################

wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/mymacchanger.py

crontab -u pi -l; echo "@reboot && /usr/bin/python3 /home/pi/mymacchanger.py >/dev/null 2>&1" | crontab -

# ###############################
# Install telegram bot
# ###############################
                                                                                                                                                             
apt install jq -y
apt install python3-pip -y
pip install telepot

wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/script.py

python3 script.py

rm script.py

mkdir /home/pi/Bots/

wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/Bot.py -P /home/pi/Bots/
wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/bot.service -P /etc/systemd/system/

pip3 install --upgrade RPi.GPIO

systemctl enable bot.service
systemctl start bot.service

# ###############################
# Heartbeat Telegram
# ###############################

crontab -u pi -l; echo '30 8 * * * curl -s -X POST https://api.telegram.org/bot5564114282:AAGSjjJkjNH7RB-4dUH-aJW1pMmquFEq-m8/sendMessage -d chat_id=90423887 -d text='BTC Loto is Alive !"' | crontab -

# ###############################
# SSH Custom Login Splash Screen
# ###############################

rm /etc/motd
touch /etc/motd

echo ' ' >> /etc/motd
echo 'GENERAL DEBUG' >> /etc/motd
echo 'sudo nano /var/log/messages' >> /etc/motd
echo 'sudo nano /var/log/kern.log' >> /etc/motd
echo 'sudo nano /var/log/syslog' >> /etc/motd
echo 'sudo tail -n 100 -f /var/log/syslog' >> /etc/motd
echo 'sudo tail -n 100 -f /var/log/messages' >> /etc/motd
echo 'sudo journalctl -xe' >> /etc/motd
echo '  ' >> /etc/motd
echo 'BOT' >> /etc/motd
echo 'sudo systemctl stop bot.service' >> /etc/motd
echo 'sudo systemctl restart bot.service' >> /etc/motd
echo 'sudo systemctl status bot.service' >> /etc/motd
echo 'sudo systemctl daemon-reload' >> /etc/motd
echo 'sudo systemctl enable bot.service' >> /etc/motd
echo 'sudo systemctl start bot.service' >> /etc/motd
echo 'sudo nano /Bots/Bot.py' >> /etc/motd
echo '  ' >> /etc/motd
echo 'BTC' >> /etc/motd
echo 'sudo tail -n 100 -f /mnt/hdd/debug.log' >> /etc/motd
echo 'bitcoin-cli getblockchaininfo' >> /etc/motd
echo '  ' >> /etc/motd
echo 'OTHER' >> /etc/motd
echo 'To reload this Splash Screen: sudo run-parts --lsbsysinit /etc/update-motd.d' >> /etc/motd
echo 'To edit the Web Monitor script: sudo nano /var/www/html/index.php' >> /etc/motd
echo 'To edit the Login Welcome script: sudo nano /etc/update-motd.d/20-raspberry-bitcoin' >> /etc/motd
echo 'To launch Glances: glances' >> /etc/motd
echo 'To Add to this splash screen edit with sudo nano  /etc/motd' >> /etc/motd
echo '  ' >> /etc/motd

# ###############################
# SSH Welcome Interface
# ###############################

wget -qO- https://gist.githubusercontent.com/meeDamian/0006c766340e0afd16936b13a0c7dbd8/raw/3b7ea819617f645ca4675f7351df70d1622863bd/na%25C3%25AFve-rbp-btc.sh | sudo sh

sudo chmod +x /etc/update-motd.d/20-raspberry-bitcoin
rm -r /etc/update-motd.d/20-raspberry-bitcoin

wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/20-raspberry-bitcoin -P /etc/update-motd.d/

chmod +x /etc/update-motd.d/20-raspberry-bitcoin
chmod -x /etc/update-motd.d/30-swap-warning
run-parts --lsbsysinit /etc/update-motd.d

# ###############################
# Uninstall Script
# ###############################

wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/uninstall.sh

# ###############################
# Final Reboot & Clean Up
# ###############################

apt autoremove -y

sudo passwd -l root
sudo shutdown -r +3 "Install Script // Reboot in 3 min"
touch done2.sh
rm install.sh
rm loader.sh



