# ###############################
# Remove Cronjob
# ###############################

crontab -u pi -r

# ###############################
# Update the software sources
# ###############################

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

sudo touch done2.sh
sudo shutdown -r +2 "loader // Shutting down in 2 min"
