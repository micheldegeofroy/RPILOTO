# ###############################
# Set Root Password
# ###############################

# echo -e "pi\npi\n" | sudo passwd root 

# ###############################
# Get Bot Token and Admin Chat ID
# ###############################

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

# Store  Chat ID to file
echo "$chat_id " >> chat_ids.txt
echo "$chat_id " >> botdata.txt
echo "$token" >> botdata.txt

# Read the telegram chat ID file and print it
ID=$(head -n 1 botdata.txt)
echo "Your Telegram Admin Chat ID is: $ID"

# Read the telegram token from file and print it
TOKEN=$(tail -n +2 botdata.txt | head -n 1)
echo "Your Telegram Bot Token is: $TOKEN"

# ###############################
# Download Install File
# ###############################

sudo wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/setup.sh"

wait

# ###############################
# Cron @ Reboot to Launch Install
# ###############################

crontab -l; echo "@reboot sleep 120 && /bin/bash /home/pi/setup.sh >/dev/null 2>&1" | crontab -

# ###############################
# Other Tasks
# ###############################

sudo shutdown -r +2
