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
# Remove Cronjob #3
# ###############################

crontab -u pi -r

touch done3.sh
# ###############################
# Update the software sources #4
# ###############################

apt update -y
apt upgrade -y

wait

# ###############################
# Web Interface #5
# ###############################

apt install php7.4 -y

sudo apt-get purge apache2 -y
sudo apt-get purge php7.4 libapache2-mod-php7.4 -y
sudo apt-get purge autoremove -y
sudo apt-get install apache2 libapache2-mod-php7.4 php7.4 -y

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/index.php" -P /var/www/html/

wait

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/miner.php" -P /var/www/html/

wait

# ###############################
# Install Tailscale #6
# ###############################

apt install apt-transport-https

curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

apt update -y
apt install tailscale -y

wait

# ###############################
# Disable Swap #7
# ###############################

swapoff --all
apt remove dphys-swapfile -y

wait

# ###############################
# Install glances #8
# ###############################

apt install python3-pip -y
pip install glances

wait

# ###############################
# Install Speed Test #9
# ###############################

sudo wget -O /usr/local/bin/speedtest-cli "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/speedtest.py"

wait

chmod a+x /usr/local/bin/speedtest-cli

wait

# ###############################
# Install watchdog #10
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

wait

# ###############################
# Stop IPV6 #11
# ###############################

echo net.ipv6.conf.all.disable_ipv6=1 | sudo tee /etc/sysctl.d/disable-ipv6.conf
sysctl --system
sed -i -e 's/$/ipv6.disable=1/' /boot/cmdline.txt

wait

# ###############################
# Disable BT #12
# ###############################

echo '# Disable Bluetooth' >> /boot/config.txt
echo 'dtoverlay=disable-bt' >> /boot/config.txt

systemctl disable hciuart.service 
systemctl disable bluetooth.service

# ###############################
# Install macchanger #13
# ###############################

wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/mymacchanger.py"

#sudo crontab -u pi -l; echo "@reboot && /usr/bin/python3 /home/pi/mymacchanger.py >/dev/null 2>&1" | crontab -

sudo crontab -u pi -l > file; echo '@reboot && /usr/bin/python3 /home/pi/mymacchanger.py >/dev/null 2>&1' >> file; crontab file

# ###############################
# Install telegram bot #14
# ###############################
                                                                                                                                                             
apt install jq -y
apt install python3-pip -y
pip install telepot

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/script.py"

wait

python3 script.py

rm script.py

mkdir /home/pi/Bots/

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/Bot.py" -P /home/pi/Bots/

wait

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/bot.service" -P /etc/systemd/system/

wait

pip3 install --upgrade RPi.GPIO

systemctl enable bot.service
systemctl start bot.service

wait

# ###############################
# Heartbeat Telegram #15
# ###############################

#crontab -u pi -l; echo '30 8 * * * curl -s -X POST https://api.telegram.org/bot5564114282:AAGSjjJkjNH7RB-4dUH-aJW1pMmquFEq-m8/sendMessage -d chat_id=90423887 -d text="BTC Loto is Alive !"' | crontab -

sudo crontab -u pi -l > file; echo '30 8 * * * curl -s -X POST https://api.telegram.org/bot5564114282:AAGSjjJkjNH7RB-4dUH-aJW1pMmquFEq-m8/sendMessage -d chat_id=90423887 -d text="BTC Loto is Alive !"' >> file; crontab file
wait

# ###############################
# SSH Custom Login Splash Screen #16
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

wait

# ###############################
# SSH Welcome Interface #17
# ###############################

mkdir -p /etc/update-motd.d/

#sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/20-raspberry-bitcoin" -P /etc/update-motd.d/
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/ssh-welcome" -P /etc/update-motd.d/

wait

#chmod +x /etc/update-motd.d/20-raspberry-bitcoin
chmod +x /etc/update-motd.d/ssh-welcome
run-parts --lsbsysinit /etc/update-motd.d

wait

# ###############################
# Uninstall Script #18
# ###############################

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/uninstall.sh"

wait

# ###############################
# Final Reboot & Clean Up #19
# ###############################

apt autoremove -y

wait

sudo shutdown -r +3
rm install.sh
rm setup.sh
rm loader.sh
rm file



