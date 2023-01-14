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
#execute the following cmd and follow the instructions when prompted
#
#sudo wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/loader.sh && sudo bash loader.sh
#
# ###############################
# Execute basic install
# ###############################
#
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

crontab -r
sudo rm setup.sh

echo " "
echo " "
echo "##########################################"
echo "Update & Upgrade Aptitude Install jq & python #4"
echo "Install jq & python3 & pip"
echo "##########################################"
echo " "
echo " "

sudo apt update -y
sudo apt upgrade -y
sudo apt install python3 -y
sudo apt install python3-pip -y
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

sudo apt install php7.4 -y
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/index.php" -P /var/www/html/
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/miner.php" -P /var/www/html/
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/favicon.ico" -P /var/www/html/

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

sudo pip install glances

echo " "
echo " "
echo "##########################################"
echo "Install Speed Test #9"
echo "##########################################"
echo " "
echo " "

sudo pip install speedtest-cli

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
echo "Install mymacchanger #13"
echo "##########################################"
echo " "
echo " "

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/mymacchanger.py" -P /home/pi/
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/mymacchanger.service" -P /etc/systemd/system/
sudo chmod +x /home/pi/mymacchanger.py
 
echo " "
echo " "
echo "##########################################"
echo "Install telegram bot #14"
echo "##########################################"
echo " "
echo " "

sudo pip install bitcoin
sudo pip install requests
sudo pip3 install python-telegram-bot==13.15 --upgrade
sudo pip install telepot
sudo pip install RPi.GPIO

sudo mkdir /home/pi/Bots/
sudo echo "0,0" | sudo tee /home/pi/Bots/btcbalance.txt

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/script.py"
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/Bot.py" -P /home/pi/Bots/
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/walletcheck.py" -P /home/pi/Bots/
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/bot.service" -P /etc/systemd/system/
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/wallet.service" -P /etc/systemd/system/

# Read the first, second and third line of the botdata.txt file
replace_value1=$(head -n 1 botdata.txt)
replace_value2=$(tail -n +2 botdata.txt | head -n 1)
replace_value3=$(tail -n +3 botdata.txt | head -n 1)
replace_value4=$(tail -n +4 botdata.txt | head -n 1)

# Replace the target value in the Bot.py script with the replacement values from botdata.txt
sed -i "s/replacewithyourapikey/$replace_value4/g" /home/pi/Bots/Bot.py 
sed -i "s/replacewithyourbottoken/$replace_value2/g" /home/pi/Bots/Bot.py  
sed -i "s/replacewithadminchatid/$replace_value1/g" /home/pi/Bots/Bot.py 
sed -i "s/1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa/$replace_value3/g" /home/pi/Bots/Bot.py 

# Replace the target value in the walletcheck.py script with the replacement values from botdata.txt
sed -i "s/replacewithyourapikey/$replace_value4/g" /home/pi/Bots/walletcheck.py 
sed -i "s/replacewithyourbottoken/$replace_value2/g" /home/pi/Bots/walletcheck.py 
sed -i "s/replacewithadminchatid/$replace_value1/g" /home/pi/Bots/walletcheck.py 
sed -i "s/1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa/$replace_value3/g" /home/pi/Bots/walletcheck.py 

# Replace the target value in the script.py script with the replacement values from botdata.txt
sed -i "s/replacewithyourbottoken/$replace_value2/g" /home/pi/script.py

sudo python3 script.py
sudo rm -r script.py

# Confirm that the replacement has been made
echo "The Admin User Chat ID, Bot Token and BTC address have been set in script.py & Bot.py & walletcheck.py files."

sudo systemctl enable bot.service
sudo systemctl start bot.service
sudo systemctl enable wallet.service
sudo systemctl start wallet.service

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

echo " "
echo " "
echo "##########################################"
echo "Final Reboot & Clean Up #19"
echo "##########################################"
echo " "
echo " "

sudo systemctl enable mymacchanger.service

sudo apt purge -y
sudo apt autoremove -y
sudo apt clean -y
sudo apt autoclean -y
sudo rm -r install.sh
sudo rm -r file
echo "Reboot Now"
sudo reboot
