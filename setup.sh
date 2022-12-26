echo " "
echo " "
echo "##########################################"
echo "Remove Previous Cronjob"
echo "##########################################"
echo " "
echo " "

sudo crontab -r

echo " "
echo " "
echo "##########################################"
echo "Update software sources & remove loader.sh"
echo "##########################################"
echo " "
echo " "

sudo apt update -y
sudo apt upgrade -y
sudo rm loader.sh

echo " "
echo " "
echo "##########################################"
echo "Fix Language Local"
echo "##########################################"
echo " "
echo " "

sudo rm /etc/environment
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

sudo crontab -l; echo "#@reboot sleep 120 && /bin/bash /home/pi/install.sh >/dev/null 2>&1" | crontab -

echo " "
echo " "
echo "##########################################"
echo "Reboot"
echo "##########################################"
echo " "
echo " "


#sudo reboot
