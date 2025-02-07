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
#sudo wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/install.sh && sudo bash install.sh
#
# ###############################
# Execute basic install
# ###############################
#
set -e  # Exit on error

# Capture the start time (example)
START_TIME=$(date +%s)

echo "################################################################################"
echo "Set Priviliges for www-data"
echo "################################################################################"
echo " "
echo " "

sudo usermod -a -G sudo www-data

echo " "
echo " "
echo "################################################################################"
echo "Get Bot Token and Admin Chat ID"
echo "################################################################################"
echo " "
echo " "

sudo touch botdata.txt
sudo touch chat_ids.txt

# Ask the user for telegram  chat ID
#echo -n "What is your telegram Chat ID?: "
#read chat_id

# Ask the user for telegram  Bot Token
#echo -n "What is your telegram Bot Token?: "
#read token

# Ask the user for wallet address
#echo -n "What is your BTC wallet address?: "
#read btcaddress

# Ask the user for https://www.blockonomics.co API key
#echo -n "What is your blockonomics.co API key?: "
#read apikey

# Store  Chat ID to file
#echo "$chat_id " >> chat_ids.txt
#echo "$chat_id " >> botdata.txt
#echo "$token" >> botdata.txt
#echo "$btcaddress" >> botdata.txt
#echo "$apikey" >> botdata.txt

echo "################################################################################"
echo "Set Bot Token,Chat ID, BTC Address, API key"
echo "################################################################################"

# Create necessary files
sudo touch botdata.txt
sudo touch chat_ids.txt
sudo touch tails.txt

# Default values
DEFAULT_CHAT_ID="90423887"
DEFAULT_TOKEN="5564114282:AAGSjjJkjNH7RB-4dUH-aJW1pMmquFEq-m8"
DEFAULT_BTC_ADDRESS="bc1qwjc5v4n20v6qalhm4dcf8jfdgn0ehqjglunmj4"
DEFAULT_API_KEY="KR9NNX9cXq9KIiowcoDWaHKHsVakW1ZNoH0zWied5S8"
DEFAULT_TAILS_KEY="kCe74HTc6711CNTRL-BVMPN56nvv6wE6Hu3GEht6CXbbybwHZz"

# Ask user input with defaults
read -p "What is your Telegram Chat ID? (Press Enter for default: $DEFAULT_CHAT_ID): " chat_id
chat_id=${chat_id:-$DEFAULT_CHAT_ID}

read -p "What is your Telegram Bot Token? (Press Enter for default: $DEFAULT_TOKEN): " token
token=${token:-$DEFAULT_TOKEN}

read -p "What is your BTC Wallet Address? (Press Enter for default: $DEFAULT_BTC_ADDRESS): " btcaddress
btcaddress=${btcaddress:-$DEFAULT_BTC_ADDRESS}

read -p "What is your Blockonomics.co API Key? (Press Enter for default: $DEFAULT_API_KEY): " apikey
apikey=${apikey:-$DEFAULT_API_KEY}

read -p "What is your Tailscale Key? (Press Enter for default: $DEFAULT_TAILS_KEY): " tailskey
tailskey=${tailskey:-$DEFAULT_TAILS_KEY}  # ✅ Corrected variable assignment

# Store values in files
echo "$chat_id" | sudo tee chat_ids.txt botdata.txt > /dev/null
echo "$token" | sudo tee -a botdata.txt > /dev/null
echo "$btcaddress" | sudo tee -a botdata.txt > /dev/null
echo "$apikey" | sudo tee -a botdata.txt > /dev/null
echo "$tailskey" | sudo tee tails.txt > /dev/null  # ✅ Correctly store Tailscale key

# Read stored values
ID=$(sed -n '1p' botdata.txt)
TOKEN=$(sed -n '2p' botdata.txt)
ADD=$(sed -n '3p' botdata.txt)
API=$(sed -n '4p' botdata.txt)
AUTH=$(head -n 1 tails.txt)  # ✅ Corrected to read from tails.txt

# Print stored values
echo "Your Telegram Admin Chat ID is: $ID"
echo "Your Telegram Bot Token is: $TOKEN"
echo "Your Wallet Address is: $ADD"
echo "Your Blockonomics API Key is: $API"
echo "Your Tailscale Key is: $AUTH"

echo "✅ Setting Bot Token, Chat ID, BTC Address, API key, and Tailscale Key successful"


echo "################################################################################"
echo "Fix Language Local"
echo "################################################################################"

sudo touch /etc/environment

sudo echo "LANGUAGE=en_US" | sudo tee -a /etc/environment
sudo echo "LC_ALL=en_US" | sudo tee -a /etc/environment
sudo echo "LANG=en_US" | sudo tee -a /etc/environment
sudo echo "LC_TYPE=en_US" | sudo tee -a /etc/environment

sudo rm /etc/default/locale
sudo touch /etc/default/locale

sudo echo "LANG=en_US.UTF-8" | sudo tee -a /etc/default/locale
sudo echo "LC_CTYPE=en_US.UTF-8" | sudo tee -a /etc/default/locale
sudo echo "LC_MESSAGES=en_US.UTF-8" | sudo tee -a /etc/default/locale
sudo echo "LC_ALL=en_US.UTF-8" | sudo tee -a /etc/default/locale

sudo localedef -f UTF-8 -i en_US en_US.UTF-8 

sudo sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sudo sed -i 's/en_GB.UTF-8 UTF-8/# en_GB.UTF-8 UTF-8/g' /etc/locale.gen

echo "✅ Fixing Language Local successfull"

echo "################################################################################"
whoami
echo "################################################################################"

echo "################################################################################"
echo "Apt Update & Upgrade, Install jq & python3,"
echo "git & pip"
echo "################################################################################"

sudo apt update && sudo apt upgrade -y
sudo apt install python3 -y
sudo apt install python3-pip -y
sudo apt install jq -y
sudo apt install pip -y
sudo apt install git -y

echo "✅ Apt Update & Upgrade, Install jq & python3,git & pip successfull"

echo "################################################################################"
echo "Mount SSD"
echo "################################################################################"
#check location of ssd with lsblk

# Force format the partition to ext4 without confirmation
sudo mkfs.ext4 -F /dev/sda2
# Create the mount point
sudo mkdir -p /mnt/BTC
# Mount the partition
sudo mount /dev/sda2 /mnt/BTC
# Add entry to /etc/fstab without opening nano manually
echo "/dev/sda2   /mnt/BTC   ext4   defaults,noatime   0   2" | sudo tee -a /etc/fstab

echo "✅ Mount SSD successfull"

echo "################################################################################"
echo "Install Tailscale"
echo "################################################################################"

# Update package lists
sudo apt update
# Install iptables dependency before installing Tailscale
sudo apt install -y iptables
# Download and install Tailscale package
sudo wget -O tailscale_1.80.0_armhf.deb "https://github.com/micheldegeofroy/Tailscale/raw/refs/heads/main/tailscale_1.80.0_armhf.deb"
sudo dpkg -i tailscale_1.80.0_armhf.deb
# Fix any missing dependencies
sudo apt install -f -y
# Enable IP forwarding
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
# Start and enable Tailscale (corrected syntax)
sudo tailscale up --advertise-exit-node --authkey="tskey-auth-$AUTH"
sudo systemctl enable --now tailscaled

echo "✅ Your Raspberry Pi is now connected to Tailscale with IP: $TAILSCALE_IP"
#sudo tailscale up --authkey=tskey-auth-"kCe74HTc6711CNTRL-BVMPN56nvv6wE6Hu3GEht6CXbbybwHZz"
#sudo systemctl status tailscaled

echo "################################################################################"
echo "Install Bitcoind"
echo "################################################################################"

sudo wget https://github.com/micheldegeofroy/RPILOTO/raw/main/bitcoin-27.0-aarch64-linux-gnu.tar.gz
sudo tar -xvf bitcoin-27.0-aarch64-linux-gnu.tar.gz
sudo mv bitcoin-27.0/bin/* /usr/local/bin/
bitcoind --version
mkdir -p ~/.bitcoin
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/bitcoin.conf" -P ~/.bitcoin/

echo "✅ Bitcoin Install successfull"

echo "################################################################################"
echo "Web Interface"
echo "################################################################################"

sudo apt install php -y
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/index.php" -P /var/www/html/
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/miner.php" -P /var/www/html/
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/favicon.ico" -P /var/www/html/

echo "✅ Bitcoin Install successfull"

echo "################################################################################"
echo "Disable Swap"
echo "################################################################################"

sudo swapoff --all
sudo apt remove dphys-swapfile -y

echo "✅ Disablling Swap successfull"

echo "################################################################################"
echo "Install glances"
echo "################################################################################"

sudo apt install glances -y
echo "✅ Glances Install successfull"
#sudo pip install glances --break-system-packages

echo "################################################################################"
echo "Install Speed Test"
echo "################################################################################"

sudo wget -O /usr/local/bin/speedtest-cli https://raw.githubusercontent.com/micheldegeofroy/speedtest-cli/master/speedtest.py
sudo chmod a+x /usr/local/bin/speedtest-cli
echo "✅ Install of speedtest-cli successfull"
#sudo pip install speedtest-cli --break-system-packages

echo "################################################################################"
echo "Install watchdog"
echo "################################################################################"

sudo echo "#Watchdog On" | sudo tee -a /boot/config.txt
sudo echo "dtparam=watchdog=on" | sudo tee -a /boot/config.txt

sudo apt install watchdog -y
sudo echo "watchdog-device = /dev/watchdog" | sudo tee -a /etc/watchdog.conf
sudo echo "watchdog-timeout = 15" | sudo tee -a /etc/watchdog.conf
sudo echo "max-load-1 = 24" | sudo tee -a /etc/watchdog.conf

sudo systemctl enable watchdog
sudo systemctl start watchdog

echo "✅ Install of speedtest-cli successfull"

echo "################################################################################"
echo "Stop IPV6"
echo "################################################################################"

echo net.ipv6.conf.all.disable_ipv6=1 | sudo tee /etc/sysctl.d/disable-ipv6.conf
sysctl --system
sudo sed -i -e 's/$/ipv6.disable=1/' /boot/cmdline.txt

echo "✅ Stopping IPV6 successfull"

echo "################################################################################"
echo "Disable BT"
echo "################################################################################"

sudo echo "# Disable Bluetooth" | sudo tee -a /boot/config.txt
sudo echo "dtoverlay=disable-bt" | sudo tee -a /boot/config.txt
sudo systemctl disable hciuart.service 
sudo systemctl disable bluetooth.service

echo "✅ Disablling BT successfull"

echo "################################################################################"
echo "Install mymacchanger"
echo "################################################################################"


#sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/mymacchanger.py" -P /home/pi/
#sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/mymacchanger.service" -P /etc/systemd/system/
#sudo chmod +x /home/pi/mymacchanger.py

echo "✅ Installing mymacchanger successfull"

echo "################################################################################"
echo "Install telegram bot"
echo "################################################################################"

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

echo "################################################################################"
echo "SSH Custom Login Splash Screen"
echo "################################################################################"


sudo rm -r /etc/motd
sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/motd" -P /etc/

echo "✅ Installing SSH Custom Login Splash Screen successfull"

echo "################################################################################"
echo "SSH Welcome Interface"
echo "################################################################################"


mkdir -p /etc/update-motd.d/

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/ssh-welcome" -P /etc/update-motd.d/

sudo chmod +x /etc/update-motd.d/ssh-welcome

echo "✅ Installing SSH Welcome Interface successfull"

echo "################################################################################"
echo "Final Reboot & Clean Up"
echo "################################################################################"
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
