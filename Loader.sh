
echo -e "pi\npi\n" | sudo passwd root 
wget https://github.com/micheldegeofroy/RPILOTO/raw/dfd465df200702a284f9386a5a3854e98d97afd4/install.sh
cronjob="@reboot sleep 120 && /home/pi/install.sh >/dev/null 2>&1"
(crontab -u root -l; echo "$cronjob" ) | crontab -u root -
reboot
