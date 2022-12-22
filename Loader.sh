
echo -e "pi\npi\n" | sudo passwd root 
wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/installtest.sh
crontab -l; echo "@reboot sleep 120 && /bin/bash /home/pi/installtest.sh >/dev/null 2>&1" | crontab -
sudo shutdown -r +2 "Loader // Shutting down in 2 min"
