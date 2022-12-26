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
#
# ###############################
# Execute basic install
# ###############################
#
#bash install.sh
#
echo " "
echo " "
echo "##########################################"
whoami
echo "##########################################"
echo " "
echo " "
echo " "
echo " "
echo "##########################################"
echo "Remove Cronjob & setup.sh #3"
echo "##########################################"
echo " "
echo " "

crontab -u pi -r
sudo rm setup.sh

echo " "
echo " "
echo "##########################################"
echo "Update & Uprade Aptitude Install jq & python #4"
echo "Install jq & python3 & pip"
echo "##########################################"
echo " "
echo " "

sudo apt update -y
sudo apt upgrade -y

sudo apt install python3 -y
apt install python3-pip -y
sudo apt install jq -y
sudo apt install pip -y
sudo apt install git -y

echo " "
echo " "
echo "##########################################"
echo "Web Interface #5"
echo "##########################################"
echo " "
echo " "

#sudo apt install php7.4 -y
sudo apt install php -y

#sudo apt purge apache2 -y
#sudo apt purge php7.4 libapache2-mod-php7.4 -y
#sudo apt purge -y
#sudo apt autoremove -y
#sudo apt clean -y
#sudo apt autoclean -y
#sudo apt install apache2 -y
#sudo apt install libapache2-mod-php7.4 -y
#sudo apt install php7.4 -y
#sudo apt autoremove -y

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/index.php" -P /var/www/html/

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/miner.php" -P /var/www/html/

echo " "
echo " "
echo "##########################################"
echo "Install Tailscale #6"
echo "##########################################"
echo " "
echo " "

sudo apt install apt-transport-https

curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

sudo apt update -y
sudo apt install tailscale -y

echo " "
echo " "
echo "##########################################"
echo "Disable Swap #7"
echo "##########################################"
echo " "
echo " "

sudo swapoff --all
sudo apt remove dphys-swapfile -y

echo " "
echo " "
echo "##########################################"
echo "Install glances #8"
echo "##########################################"
echo " "
echo " "

#sudo apt install pip -y
sudo pip install glances
#sudo snap install core
#sudo snap install glances
#sudo apt install python3-pip -y
#sudo pip install glances

echo " "
echo " "
echo "##########################################"
echo "Install Speed Test #9"
echo "##########################################"
echo " "
echo " "

sudo wget -O /usr/local/bin/speedtest-cli "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/speedtest.py"

chmod a+x /usr/local/bin/speedtest-cli

echo " "
echo " "
echo "##########################################"
echo "Install watchdog #10"
echo "##########################################"
echo " "
echo " "

sudo echo "#Watchdog On" | sudo tee -a /boot/config.txt
sudo echo "dtparam=watchdog=on" | sudo tee -a /boot/config.txt

sudo apt install watchdog -y

sudo echo "watchdog-device = /dev/watchdog" | sudo tee -a /etc/watchdog.conf
sudo echo "watchdog-timeout = 15" | sudo tee -a /etc/watchdog.conf
sudo echo "max-load-1 = 24" | sudo tee -a /etc/watchdog.conf

sudo systemctl enable watchdog
sudo systemctl start watchdog
#sudo systemctl status watchdog

echo " "
echo " "
echo "##########################################"
echo "Stop IPV6 #11"
echo "##########################################"
echo " "
echo " "

echo net.ipv6.conf.all.disable_ipv6=1 | sudo tee /etc/sysctl.d/disable-ipv6.conf
sysctl --system
sudo sed -i -e 's/$/ipv6.disable=1/' /boot/cmdline.txt

echo " "
echo " "
echo "##########################################"
echo "Disable BT #12"
echo "##########################################"
echo " "
echo " "

sudo echo "# Disable Bluetooth" | sudo tee -a /boot/config.txt
sudo echo "dtoverlay=disable-bt" | sudo tee -a /boot/config.txt

sudo systemctl disable hciuart.service 
sudo systemctl disable bluetooth.service

echo " "
echo " "
echo "##########################################"
echo "Install macchanger #13"
echo "##########################################"
echo " "
echo " "

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/mymacchanger.py"

#sudo crontab -u pi -l; echo "@reboot && /usr/bin/python3 /home/pi/mymacchanger.py >/dev/null 2>&1" | crontab -

sudo crontab -l > file; echo '@reboot && /usr/bin/python3 /home/pi/mymacchanger.py >/dev/null 2>&1' >> file; crontab file
 
sudo crontab -l
 
echo " "
echo " "
echo "##########################################"
echo "Install telegram bot #14"
echo "##########################################"
echo " "
echo " "

#sudo apt install python3 -y
#sudo apt install jq -y
#sudo apt install python3-pip -y
sudo pip install python-telegram-bot
sudo pip install telepot
sudo pip3 install --upgrade RPi.GPIO

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/script.py"

sudo python3 script.py

sudo rm -r script.py

sudo mkdir /home/pi/Bots/

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/Bot.py" -P /home/pi/Bots/

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/bot.service" -P /etc/systemd/system/

# Read the first and second line of the botdata.txt file
replace_value1=$(head -n 1 botdata.txt)
replace_value2=$(tail -n +2 botdata.txt | head -n 1)

# Replace the target value in the Bot.py script with the replacement values from botdata.txt
sed -i "s/replacewithyourbottoken/$replace_value2/g" /Bots/Bot.py 
sed -i "s/replacewithadminchatid/$replace_value1/g" /Bots/Bot.py

# Confirm that the replacement has been made
echo "The Admin User Chat ID and Bot Token have been set in Bot.py file."

sudo systemctl enable bot.service
sudo systemctl start bot.service

echo " "
echo " "
echo "##########################################"
echo "Heartbeat Telegram #15"
echo "##########################################"
echo " "
echo " "

#crontab -u pi -l; echo '30 8 * * * curl -s -X POST https://api.telegram.org/bot5564114282:AAGSjjJkjNH7RB-4dUH-aJW1pMmquFEq-m8/sendMessage -d chat_id=90423887 -d text="BTC Loto is Alive !"' | crontab -

sudo crontab -l > file; echo '30 8 * * * curl -s -X POST https://api.telegram.org/bot5564114282:AAGSjjJkjNH7RB-4dUH-aJW1pMmquFEq-m8/sendMessage -d chat_id=90423887 -d text="BTC Loto is Alive !"' >> file; crontab file

sudo crontab -l

echo " "
echo " "
echo "##########################################"
echo "SSH Custom Login Splash Screen #16"
echo "##########################################"
echo " "
echo " "

sudo rm -r /etc/motd

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/motd" -P /etc/

echo " "
echo " "
echo "##########################################"
echo "SSH Welcome Interface #17"
echo "##########################################"
echo " "
echo " "

mkdir -p /etc/update-motd.d/

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/ssh-welcome" -P /etc/update-motd.d/

sudo chmod +x /etc/update-motd.d/ssh-welcome
#sudo run-parts --lsbsysinit /etc/update-motd.d

echo " "
echo " "
echo "##########################################"
echo "Uninstall Script #18"
echo "##########################################"
echo " "
echo " "

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/uninstall.sh"

echo " "
echo " "
echo "##########################################"
echo "Final Reboot & Clean Up #19"
echo "##########################################"
echo " "
echo " "

sudo apt purge -y
sudo apt autoremove -y
sudo apt clean -y
sudo apt autoclean -y
sudo rm -r install.sh
sudo rm -r file
#sudo reboot


