
echo -e "pi\npi\n" | sudo passwd root 
wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/install.sh
cronjob="@reboot sleep 120 && /home/pi/install.sh >/dev/null 2>&1"
(crontab -u root -l; echo "$cronjob" ) | crontab -u root -
reboot
