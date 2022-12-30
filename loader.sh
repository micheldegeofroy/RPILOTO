# ###############################
# Set Root Password
# ###############################

# echo -e "pi\npi\n" | sudo passwd root 

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

sudo rm botdata.txt
sudo rm chat_ids.txt

sudo touch botdata.txt
sudo touch chat_ids.txt

# Ask the user for telegram  chat ID
echo -n "What is your telegram Chat ID?: "
read chat_id

# Ask the user for telegram  Bot Token
echo -n "What is your telegram Bot Token?: "
read token

# Ask the user for wallet address
echo -n "What is your telegram Bot Token?: "
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
echo "Your Wallet Address is: $TOKEN"

# Read the btcaddress  from file and print it
API=$(tail -n +3 botdata.txt | head -n 1)
echo "Your Wallet Address is: $TOKEN"

echo " "
echo " "
echo "##########################################"
echo "Download Install File"
echo "##########################################"
echo " "
echo " "

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/setup.sh"

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
echo "Cron @ Reboot to Launch Install"
echo "##########################################"
echo " "
echo " "

crontab -l; echo "#@reboot sleep 60 && /bin/bash /home/pi/setup.sh >/dev/null 2>&1" | crontab -

echo " "
echo " "
echo "##########################################"
echo "Reboot"
echo "##########################################"
echo " "
echo " "

#sudo reboot
