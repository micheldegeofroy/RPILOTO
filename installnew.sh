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
set -e  # Exit on error

# Capture the start time (example)
START_TIME=$(date +%s)

echo " "
echo " "
echo "##########################################"
whoami
echo "##########################################"
echo " "
echo " "
echo "##########################################"
echo "Remove Cronjob & setup.sh"
echo "##########################################"

crontab -r
sudo rm setup.sh

echo "✅ Removal of Cronjob & setup.sh successfull"

echo "##########################################"
echo "Apt Update & Upgrade, Install jq & python3,"
echo "git & pip"
echo "##########################################"

sudo apt update && sudo apt upgrade -y
sudo apt install python3 -y
sudo apt install python3-pip -y
sudo apt install jq -y
sudo apt install pip -y
sudo apt install git -y

echo "✅ Apt Update & Upgrade, Install jq & python3,git & pip successfull"

echo "##########################################"
echo "Mount SSD"
echo "##########################################"
#check location of ssd with lsblk

sudo mkfs.ext4 /dev/sda2
sudo mkdir -p /mnt/BTC
sudo mount /dev/sda2 /mnt/BTC
sudo nano /etc/fstab
echo "/dev/sda1   /mnt/bitcoin   ext4   defaults,noatime   0   2" | sudo tee -a /etc/fstab
cat /etc/fstab

echo "✅ Mount SSD successfull"

echo "##########################################"
echo "Install Bitcoind"
echo "##########################################"

sudo wget https://github.com/micheldegeofroy/RPILOTO/raw/main/bitcoin-27.0-aarch64-linux-gnu.tar.gz
sudo tar -xvf bitcoin-27.0-aarch64-linux-gnu.tar.gz
sudo mv bitcoin-27.0/bin/* /usr/local/bin/
bitcoind --version
mkdir -p ~/.bitcoin
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/bitcoin.conf" -P ~/.bitcoin/

echo "✅ Bitcoin Install successfull"

echo "##########################################"
echo "Web Interface"
echo "##########################################"

sudo apt install php -y
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/index.php" -P /var/www/html/
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/miner.php" -P /var/www/html/
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/favicon.ico" -P /var/www/html/

echo "✅ Bitcoin Install successfull"

echo "##########################################"
echo "Disable Swap"
echo "##########################################"

sudo swapoff --all
sudo apt remove dphys-swapfile -y

echo "✅ Disablling Swap successfull"

echo "##########################################"
echo "Install glances"
echo "##########################################"

sudo apt install glances -y
echo "✅ Glances Install successfull"
#sudo pip install glances --break-system-packages

echo "##########################################"
echo "Install Speed Test"
echo "##########################################"

sudo wget -O /usr/local/bin/speedtest-cli https://raw.githubusercontent.com/micheldegeofroy/speedtest-cli/master/speedtest.py
sudo chmod a+x /usr/local/bin/speedtest-cli
echo "✅ Install of speedtest-cli successfull"
#sudo pip install speedtest-cli --break-system-packages

echo "##########################################"
echo "Install watchdog"
echo "##########################################"

sudo echo "#Watchdog On" | sudo tee -a /boot/config.txt
sudo echo "dtparam=watchdog=on" | sudo tee -a /boot/config.txt

sudo apt install watchdog -y
sudo echo "watchdog-device = /dev/watchdog" | sudo tee -a /etc/watchdog.conf
sudo echo "watchdog-timeout = 15" | sudo tee -a /etc/watchdog.conf
sudo echo "max-load-1 = 24" | sudo tee -a /etc/watchdog.conf

sudo systemctl enable watchdog
sudo systemctl start watchdog

echo "✅ Install of speedtest-cli successfull"

echo "##########################################"
echo "Stop IPV6"
echo "##########################################"

echo net.ipv6.conf.all.disable_ipv6=1 | sudo tee /etc/sysctl.d/disable-ipv6.conf
sysctl --system
sudo sed -i -e 's/$/ipv6.disable=1/' /boot/cmdline.txt

echo "✅ Stopping IPV6 successfull"

echo "##########################################"
echo "Disable BT"
echo "##########################################"

sudo echo "# Disable Bluetooth" | sudo tee -a /boot/config.txt
sudo echo "dtoverlay=disable-bt" | sudo tee -a /boot/config.txt
sudo systemctl disable hciuart.service 
sudo systemctl disable bluetooth.service

echo "✅ Disablling BT successfull"

echo "##########################################"
echo "Install mymacchanger"
echo "##########################################"


#sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/mymacchanger.py" -P /home/pi/
#sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/mymacchanger.service" -P /etc/systemd/system/
#sudo chmod +x /home/pi/mymacchanger.py

echo "✅ Installing mymacchanger successfull"

echo "##########################################"
echo "Install telegram bot"
echo "##########################################"

sudo pip install bitcoin --break-system-packages
sudo pip install requests --break-system-packages
sudo pip3 install python-telegram-bot==13.15 --upgrade --break-system-packages
sudo pip install telepot --break-system-packages
sudo pip install RPi.GPIO --break-system-packages

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

echo "✅ Installing telegram bot successfull"

echo "##########################################"
echo "SSH Custom Login Splash Screen"
echo "##########################################"


sudo rm -r /etc/motd
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/motd" -P /etc/

echo "✅ Installing SSH Custom Login Splash Screen successfull"

echo "##########################################"
echo "SSH Welcome Interface"
echo "##########################################"


mkdir -p /etc/update-motd.d/

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/ssh-welcome" -P /etc/update-motd.d/

sudo chmod +x /etc/update-motd.d/ssh-welcome

echo "✅ Installing SSH Welcome Interface successfull"

echo "##########################################"
echo "Final Reboot & Clean Up"
echo "##########################################"
echo " "
echo " "

#sudo systemctl enable mymacchanger.service

sudo rm -r file
sudo apt purge -y
sudo apt autoremove -y
sudo apt clean
sudo apt autoclean -y

(sleep 60 && sudo reboot) &
echo "Deleting the install script..."
rm -- "$0" || { echo "Error deleting the install script"; exit 1; }
echo "Install script deleted."

# Capture the end time
END_TIME=$(date +%s)

# Calculate the execution time in seconds
EXECUTION_TIME=$((END_TIME - START_TIME))

# Convert seconds to hours, minutes, and seconds
HOURS=$((EXECUTION_TIME / 3600))
MINUTES=$(( (EXECUTION_TIME % 3600) / 60 ))
SECONDS=$((EXECUTION_TIME % 60))

# Format the output
echo "Execution time: ${HOURS} hr/s ${MINUTES} min/s ${SECONDS} sec/s"

echo "################################################################################"
echo "Script execution time: $EXECUTION_TIME seconds."
echo "################################################################################"

sudo journalctl -p err -b
