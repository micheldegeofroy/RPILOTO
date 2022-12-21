
echo -e "pi\npi\n" | sudo passwd root 
wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/install.sh
cronjob="@reboot root sleep 120 && /home/pi/install.sh >/dev/null 2>&1"
(crontab -l; echo "$cronjob" )
sudo reboot
