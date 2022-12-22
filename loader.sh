# ###############################
# Set Root Password
# ###############################

echo -e "pi\npi\n" | sudo passwd root 

# ###############################
# Download Install File
# ###############################

wget "https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/setup.sh"

wait

# ###############################
# Cron @ Reboot to Launch Install
# ###############################

crontab -l; echo "@reboot sleep 120 && /bin/bash /home/pi/setup.sh >/dev/null 2>&1" | crontab -

# ###############################
# Other Tasks
# ###############################

sudo touch done1.sh
sudo shutdown -r +2 "loader // Shutting down in 2 min"
