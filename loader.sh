# ###############################
# Fix Language Local
# ###############################

sudo rm /etc/environment
sudo touch /etc/environment

sudo echo "LANGUAGE=en_US" >> /etc/environment
sudo echo "LC_ALL=en_US" >> /etc/environment
sudo echo "LANG=en_US" >> /etc/environment
sudo echo "LC_TYPE=en_US" >> /etc/environment

sudo rm /etc/default/locale
sudo touch /etc/default/locale

sudo echo "LANG=en_US.UTF-8" >> /etc/default/locale
sudo echo "LC_CTYPE=en_US.UTF-8" >> /etc/default/locale
sudo echo "LC_MESSAGES=en_US.UTF-8" >> /etc/default/locale
sudo echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale

sudo localedef -f UTF-8 -i en_US en_US.UTF-8 

sudo sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sudo sed -i 's/en_GB.UTF-8 UTF-8/# en_GB.UTF-8 UTF-8/g' /etc/locale.gen

# ###############################
# Set Root Password
# ###############################

echo -e "pi\npi\n" | sudo passwd root 

# ###############################
# Download Install File
# ###############################

wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/install.sh

# ###############################
# Cron @ Reboot to Launch Install
# ###############################

crontab -l; echo "@reboot sleep 120 && /bin/bash /home/pi/install.sh >/dev/null 2>&1" | crontab -

# ###############################
# Other Tasks
# ###############################

sudo touch done1.sh
sudo shutdown -r +2 "loader // Shutting down in 2 min"
