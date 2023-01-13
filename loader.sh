# ###############################
# Set Root Password
# ###############################

echo " "
echo " "
echo "##########################################"
echo "Update software sources & remove loader.sh"
echo "##########################################"
echo " "
echo " "

sudo apt update -y
sudo apt upgrade -y

echo " "
echo " "
echo "##########################################"
echo "Set Priviliges for www-data"
echo "##########################################"
echo " "
echo " "

sudo usermod -a -G sudo www-data

echo " "
echo " "
echo "##########################################"
echo "Get Bot Token and Admin Chat ID"
echo "##########################################"
echo " "
echo " "

sudo touch botdata.txt
sudo touch chat_ids.txt

# Ask the user for telegram  chat ID
echo -n "What is your telegram Chat ID?: "
read chat_id

# Ask the user for telegram  Bot Token
echo -n "What is your telegram Bot Token?: "
read token

# Ask the user for wallet address
echo -n "What is your BTC wallet address?: "
read btcaddress

# Ask the user for https://www.blockonomics.co API key
echo -n "What is your blockonomics.co API key?: "
read apikey

# Store  Chat ID to file
echo "$chat_id " >> chat_ids.txt
echo "$chat_id " >> botdata.txt
echo "$token" >> botdata.txt
echo "$btcaddress" >> botdata.txt
echo "$apikey" >> botdata.txt

# Read the telegram chat ID file and print it
ID=$(head -n 1 botdata.txt)
echo "Your Telegram Admin Chat ID is: $ID"

# Read the telegram token from file and print it
TOKEN=$(tail -n +2 botdata.txt | head -n 1)
echo "Your Telegram Bot Token is: $TOKEN"

# Read the btcaddress  from file and print it
ADD=$(tail -n +3 botdata.txt | head -n 1)
echo "Your Wallet Address is: $ADD"

# Read the btcaddress  from file and print it
API=$(tail -n +3 botdata.txt | head -n 1)
echo "Your Wallet Address is: $API"

echo " "
echo " "
echo "##########################################"
echo "Download Install File"
echo "##########################################"
echo " "
echo " "

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/install.sh"

echo " "
echo " "
echo "##########################################"
echo "Fix Language Local"
echo "##########################################"
echo " "
echo " "

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

echo " "
echo " "
echo "##########################################"
echo "Cron @ Reboot to Launch Install"
echo "##########################################"
echo " "
echo " "

sudo crontab -l; echo "#@reboot sleep 120 && /bin/bash /home/pi/install.sh >/dev/null 2>&1" | crontab -

echo " "
echo " "
echo "##########################################"
echo "Reboot"
echo "##########################################"
echo " "
echo " "

sudo reboot
